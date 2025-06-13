class ImportMailer < ApplicationMailer
  def import_completed(user, result)
    @user = user
    @result = result
    @imported = result[:imported]
    @errors = result[:errors]
    @duration = result[:duration]

    mail(
      to: @user.email,
      subject: "CSV Import Completed - #{@imported} records imported"
    )
  end
end 