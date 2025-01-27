RSpec.describe AvisMailer, type: :mailer do
  describe '.avis_invitation' do
    let(:claimant) { create(:instructeur) }
    let(:expert) { create(:expert) }
    let(:dossier) { create(:dossier, :en_construction) }
    let(:experts_procedure) { create(:experts_procedure, expert: expert, procedure: dossier.procedure) }
    let(:avis) { create(:avis, dossier: dossier, claimant: claimant, experts_procedure: experts_procedure, introduction: 'intro') }

    subject { described_class.avis_invitation(avis.reload) }

    it { expect(subject.subject).to eq("Donnez votre avis sur le dossier nº #{avis.dossier.id} (#{avis.dossier.procedure.libelle})") }
    it { expect(subject.body).to have_text("Vous avez été invité par\r\n#{avis.claimant.email}\r\nà donner votre avis sur le dossier nº #{avis.dossier.id} de la démarche :\r\n#{avis.dossier.procedure.libelle}") }
    it { expect(subject.body).to include(avis.introduction) }
    it { expect(subject.body).to include(instructeur_avis_url(avis.dossier.procedure.id, avis)) }

    context 'when the recipient is not already registered' do
      it { expect(subject.body).to include(sign_up_expert_avis_url(avis.dossier.procedure.id, avis.id, email: avis.expert.email)) }
    end

    context 'when the dossier has been deleted before the avis was sent' do
      before { dossier.update(hidden_by_user_at: 1.hour.ago) }

      it 'doesn’t send the email' do
       expect(subject.body).to be_blank
     end
    end
  end
end
