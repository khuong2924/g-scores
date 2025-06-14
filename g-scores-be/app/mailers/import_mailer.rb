class ImportMailer < ApplicationMailer
  def import_completed(email, result)
    @result = result
    @imported = result[:imported]
    @errors = result[:errors]
    @duration = result[:duration]

    mail(
      to: email,
      subject: "CSV Import Completed - #{@imported} records imported"
    )
  end
end 