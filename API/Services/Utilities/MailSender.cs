using System.Net;
using System.Net.Mail;
using TestRestAPI.Models.Utilities;

namespace PCFitment_API.Services
{
    public class MailSender
    {
        public static bool SendEmail(string pSubject, string pMessage, out string responseMessage)
        {
            bool status = false;
            responseMessage = string.Empty;

            // Check if the subject and message are provided
            if (string.IsNullOrEmpty(pSubject) || string.IsNullOrEmpty(pMessage))
            {
                responseMessage = "Subject or Message cannot be empty.";
                return status; // return false immediately if subject or message is missing
            }

            var emailSettings = commonMethods.GetEmailSettings();

            // Check if any essential email settings are null or empty
            if (string.IsNullOrEmpty(emailSettings.FromEmail) ||
                string.IsNullOrEmpty(emailSettings.FromPass) ||
                string.IsNullOrEmpty(emailSettings.Smtp) ||
                string.IsNullOrEmpty(emailSettings.ErrorTo))
            {
                responseMessage = "Email settings are not properly configured.";
                return status; // return false if any essential settings are missing
            }

            string pSMTP = emailSettings.Smtp;
            string pFromEmail = emailSettings.FromEmail;
            string pPass = emailSettings.FromPass;
            string pFromDisplayName = emailSettings.DisplayName;
            string pErrorTo = emailSettings.ErrorTo;
            string pErrorBcc = emailSettings.ErrorBcc;
            string pErrorCc = emailSettings.ErrorCc;

            try
            {
                using (MailMessage mm = new MailMessage())
                {
                    // Check and set From Address
                    if (!string.IsNullOrEmpty(pFromDisplayName))
                        mm.From = new MailAddress(pFromEmail, pFromDisplayName);
                    else
                        mm.From = new MailAddress(pFromEmail);

                    // Check and add To Recipients
                    string[] to = pErrorTo.Split(';');
                    foreach (string recipient in to)
                    {
                        if (!string.IsNullOrEmpty(recipient))
                            mm.To.Add(new MailAddress(recipient));
                    }

                    // Check and add Bcc Recipients
                    if (!string.IsNullOrEmpty(pErrorBcc))
                    {
                        string[] bcc = pErrorBcc.Split(';');
                        foreach (string recipient in bcc)
                        {
                            if (!string.IsNullOrEmpty(recipient))
                                mm.Bcc.Add(new MailAddress(recipient));
                        }
                    }

                    // Check and add CC Recipients
                    if (!string.IsNullOrEmpty(pErrorCc))
                    {
                        string[] cc = pErrorCc.Split(';');
                        foreach (string recipient in cc)
                        {
                            if (!string.IsNullOrEmpty(recipient))
                                mm.CC.Add(new MailAddress(recipient));
                        }
                    }

                    // Set subject and body
                    mm.Subject = pSubject;
                    mm.Body = pMessage;
                    mm.IsBodyHtml = true;

                    using (SmtpClient smtp = new SmtpClient())
                    {
                        smtp.Host = pSMTP;
                        smtp.EnableSsl = true;
                        NetworkCredential networkCred = new NetworkCredential(pFromEmail, pPass);
                        smtp.UseDefaultCredentials = false;
                        smtp.Credentials = networkCred;
                        smtp.Port = 587; // Ensure this is the correct port

                        smtp.Send(mm);
                        mm.Attachments.Dispose();
                    }

                    status = true;
                    responseMessage = "Email sent successfully.";
                }
            }
            catch (Exception ex)
            {
                responseMessage = $"Error sending email: {ex.Message}";
                status = false;
            }

            return status;
        }
    }
}
