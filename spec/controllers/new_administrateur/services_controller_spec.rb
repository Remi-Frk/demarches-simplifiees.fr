describe NewAdministrateur::ServicesController, type: :controller do
  let(:admin) { create(:administrateur) }

  describe '#create' do
    before do
      sign_in admin
      post :create, params: params
    end

    context 'when submitting a new service' do
      let(:params) do
        {
          service: {
            nom: 'super service',
            type_organisme: 'region'
          },
          procedure_id: 12
        }
      end

      it { expect(flash.alert).to be_nil }
      it { expect(flash.notice).to eq('super service créé') }
      it { expect(Service.last.nom).to eq('super service') }
      it { expect(Service.last.type_organisme).to eq('region') }
      it { expect(response).to redirect_to(services_path(procedure_id: 12)) }
    end

    context 'when submitting an invalid service' do
      let(:params) { { service: { nom: 'super service' } } }

      it { expect(flash.alert).not_to be_nil }
      it { expect(response).to render_template(:new) }
    end
  end

  describe '#update' do
    let!(:service) { create(:service, administrateur: admin) }
    let(:service_params) { { nom: 'nom', type_organisme: 'region' } }

    before do
      sign_in admin
      params = {
        id: service.id,
        service: service_params,
        procedure_id: 12
      }
      patch :update, params: params
    end

    context 'when updating a service' do
      it { expect(flash.alert).to be_nil }
      it { expect(flash.notice).to eq('nom modifié') }
      it { expect(Service.last.nom).to eq('nom') }
      it { expect(Service.last.type_organisme).to eq('region') }
      it { expect(response).to redirect_to(services_path(procedure_id: 12)) }
    end

    context 'when updating a service with invalid data' do
      let(:service_params) { { nom: '', type_organisme: 'region' } }

      it { expect(flash.alert).not_to be_nil }
      it { expect(response).to render_template(:edit) }
    end
  end

  describe '#add_to_procedure' do
    let!(:procedure) { create(:procedure, administrateur: admin) }
    let!(:service) { create(:service, administrateur: admin) }

    def post_add_to_procedure
      sign_in admin
      params = {
        procedure: {
          id: procedure.id,
          service_id: service.id
        }
      }
      patch :add_to_procedure, params: params
      procedure.reload
    end

    context 'when adding a service to a procedure' do
      before { post_add_to_procedure }

      it { expect(flash.alert).to be_nil }
      it { expect(flash.notice).to eq("service affecté : #{service.nom}") }
      it { expect(procedure.service_id).to eq(service.id) }
      it { expect(response).to redirect_to(admin_procedure_path(procedure.id)) }
    end

    context 'when stealing a service to add it to a procedure' do
      let!(:service) { create(:service) }

      it { expect { post_add_to_procedure }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end
end
