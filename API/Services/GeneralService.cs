using Dapper;
using Newtonsoft.Json;
using PartsConnectWebTools.Helpers;
using PartsConnectWebTools.Models.Custom;
using PCFitment_API.Models;
using System.Data;
using System.Data.SqlClient;
using System.Net;
using System.Net.Http.Headers;
using System.Net.Mail;
using System.Text;
using TestRestAPI.Models.Utilities;
using Google.Apis.Auth.OAuth2;
using Microsoft.AspNetCore.Http;

namespace PCFitment_API.Services
{
    public class GeneralService
    {
        StringBuilder stbSqlQuery = new StringBuilder();
        string connString = clsConnection.CommonConnString();
        int gblIntcount = 0;
        private static string _cachedToken;
        private static DateTime _tokenExpiryTime;
        private static readonly string[] Scopes = { "https://www.googleapis.com/auth/userinfo.email", "https://www.googleapis.com/auth/firebase.database", "https://www.googleapis.com/auth/firebase.messaging" };

        //--------------* Get Help Videos Start *-----------------------//

        public object GetHelpVideosDetails()
        {
            IEnumerable<MDLGetHelpVideosDetails> mDLGetHelpVideosDetails;
            StringBuilder stbSqlQuery = new StringBuilder();

            using (var conn = new SqlConnection(clsConnection.CommonConnString()))
            {
                conn.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@"SELECT * FROM [dbo].[App_Help_Videos] WHERE IsActive = 1 ORDER BY Sort ");
                mDLGetHelpVideosDetails = conn.Query<MDLGetHelpVideosDetails>(stbSqlQuery.ToString()).ToList();
                conn.Close();
            }

            return mDLGetHelpVideosDetails;
        }
        public string SendNotification(MDLSendNotification mDLSendNotification)
        {
            string msg = "";
            try
            {
                bool IsSent = false;
                int RecordId = 0;
                string FirebaseProjectKey = commonMethods.GetFirebaseProjectkey();

                // Get the FCM token list for the tenant
                DataTable FCMTokenList = CustomerHelper.GetFCMTokenListForApp(Convert.ToInt32(mDLSendNotification.TenantID));

                // Handle NotificationDate, if it's empty assign current date-time in the required format
                if (string.IsNullOrEmpty(mDLSendNotification.NotificationDate))
                {
                    mDLSendNotification.NotificationDate = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
                }

                if (FCMTokenList.Rows.Count > 0)
                {
                    RecordId = CustomerHelper.AddAppCustomNotification(mDLSendNotification.NotificationTitle, mDLSendNotification.NotificationMessage, mDLSendNotification.NotificationDate, Convert.ToInt32(mDLSendNotification.TenantID));

                    int tempTenantID = 0;
                    string FCMToken = "";

                    for (int IntI = 0; IntI < FCMTokenList.Rows.Count; IntI++)
                    {
                        if (FCMToken != Convert.ToString(FCMTokenList.Rows[IntI]["FCMToken"]))
                        {
                            //IsSent = SendAppCustomNotification(FirebaseServerkey, Convert.ToString(FCMTokenList.Rows[IntI]["FCMToken"]), mDLSendNotification.NotificationTitle, mDLSendNotification.NotificationMessage, mDLSendNotification.NotificationDate, true);
                            // Sending notification and checking the result
                            var (status, message) = SendAppCustomNotification(
                                FirebaseProjectKey,
                                Convert.ToString(FCMTokenList.Rows[IntI]["FCMToken"]),
                                mDLSendNotification.NotificationTitle,
                                mDLSendNotification.NotificationMessage
                            );

                            IsSent = status;

                            //Need to entry to trace
                            CustomerHelper.AddApp_Notification_Trace(Convert.ToString(FCMTokenList.Rows[IntI]["App_SettingsID"]), Convert.ToString(RecordId), Convert.ToString(FCMTokenList.Rows[IntI]["TenantID"]), IsSent, message);
                        }

                        FCMToken = Convert.ToString(FCMTokenList.Rows[IntI]["FCMToken"]);

                        if (tempTenantID != Convert.ToInt32(FCMTokenList.Rows[IntI]["TenantID"]))
                        {
                            //CustomerHelper.AddAppCustomNotification_History(mDLSendNotification.Notification_Type, Convert.ToInt32(FCMTokenList.Rows[IntI]["TenantID"]), mDLSendNotification.NotificationTitle, mDLSendNotification.NotificationMessage, "", RecordId);
                            CustomerHelper.AddAppCustomNotification_History(
                                mDLSendNotification.Notification_Type,
                                Convert.ToInt32(FCMTokenList.Rows[IntI]["TenantID"]),
                                mDLSendNotification.NotificationTitle,
                                mDLSendNotification.NotificationMessage,
                                RecordId
                            );
                        }
                        tempTenantID = Convert.ToInt32(FCMTokenList.Rows[IntI]["TenantID"]);
                    }

                    msg = "S" + "|" + "Notification sent successfully!";
                }

            }
            catch (Exception ex)
            {
                msg = "F" + "|" + ex.Message + ", Please contact system admin!";
            }
            return msg;
        }
        public (bool status, string message) SendAppCustomNotification(string firebaseProjectKey, string token, string title, string body)
        {
            try
            {
                var messageContent = new
                {
                    message = new
                    {
                        token = token,
                        notification = new
                        {
                            title = title,
                            body = body
                        }
                    }
                };

                var jsonMessage = JsonConvert.SerializeObject(messageContent);
                var httpRequest = new HttpRequestMessage(HttpMethod.Post, firebaseProjectKey)
                {
                    Content = new StringContent(jsonMessage, Encoding.UTF8, "application/json")
                };

                using (var client = new HttpClient())
                {
                    client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", GetFirebaseAccessToken());

                    var response = client.SendAsync(httpRequest).Result;

                    if (response.IsSuccessStatusCode)
                    {
                        CustomerHelper.AddApp_Notification_Trace();
                        return (true, "Notification sent successfully.");
                    }
                    else
                    {
                        return (false, $"Failed to send notification. Error: {response.ReasonPhrase}");
                    }
                }
            }
            catch (Exception ex)
            {
                return (false, $"Exception: {ex.Message}");
            }
        }

        public string GetFirebaseAccessToken()
        {
            if (_cachedToken == null || DateTime.UtcNow >= _tokenExpiryTime)
            {
                var jsonPath = commonMethods.JsonPhysicalPath() + @"serviceAccountKey.json";
                GoogleCredential credential; using (var stream = new FileStream(jsonPath, FileMode.Open, FileAccess.Read)) { credential = GoogleCredential.FromStream(stream).CreateScoped(Scopes); }

                _cachedToken = credential.UnderlyingCredential.GetAccessTokenForRequestAsync().Result;
                _tokenExpiryTime = DateTime.UtcNow.AddMinutes(55);
            }

            return _cachedToken;
        }
        public IEnumerable<MDLBrandCode> GetBrands(int tenantID)
        {
            IEnumerable<MDLBrandCode> mDLBrandCodes;
            StringBuilder stbSqlQuery = new StringBuilder();

            using (var conn = new SqlConnection(clsConnection.CommonConnString()))
            {
                conn.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@" SELECT BrandName+' ('+BrandCode+')' As Text,
                                      BrandCode As Value,
                                      CASE WHEN ISNULL(IsBrandVerified,0) = 1 THEN 'Yes' ELSE 'No' END AS 'IsBrandVerifiedtxt'
                                      from tools.Brand 
                                      WHERE TenantID = @TenantID  AND ISNULL(IsDeleted, 0) = 0 ");
                mDLBrandCodes = conn.Query<MDLBrandCode>(stbSqlQuery.ToString(), new { TenantID = tenantID }).ToList();
                conn.Close();
            }

            return mDLBrandCodes;
        }
        public string SendErrorEmail(MDLSendErrorEmail mDLSendErrorEmail)
        {
            string msg = "";
            try
            {
                // Call SendEmail with out parameter for responseMessage
                string responseMessage;
                bool isSent = MailSender.SendEmail(mDLSendErrorEmail.Subject, mDLSendErrorEmail.Message, out responseMessage);

                if (isSent)
                {
                    msg = "S" + "|" + "Error email sent successfully.";
                }
                else
                {
                    msg = "F" + "|" + responseMessage + ", Please contact system admin!";
                }
            }
            catch (Exception ex)
            {
                msg = "F" + "|" + ex.Message + ", Please contact system admin!";
            }
            return msg;
        }
    }
}
