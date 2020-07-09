namespace :after_party do
  desc 'Deployment task: add_default_skip_validation_to_piece_justificative'
  task add_default_skip_validation_to_piece_justificative: :environment do
    puts "Running deploy task 'add_default_skip_validation_to_piece_justificative'"

    tdcs = TypeDeChamp.where(type_champ: TypeDeChamp.type_champs.fetch(:piece_justificative))
    progress = ProgressReport.new(tdcs.count)
    tdcs.find_each do |tdc|
      tdc.update(options: tdc.options&.merge({ :skip_pj_validation => true }) || { :skip_pj_validation => true })
      progress.inc
    end
    progress.finish

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20200708101123'
  end
end
