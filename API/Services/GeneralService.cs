using Dapper;
using Newtonsoft.Json;
using PartsConnectWebTools.Helpers;
using PartsConnectWebTools.Models.Custom;
using PCFitment_API.Models;
using System.Data;
using System.Data.SqlClient;
using System.Net;
using System.Text;
using TestRestAPI.Models.Utilities;

namespace PCFitment_API.Services
{
    public class GeneralService
    {
        StringBuilder stbSqlQuery = new StringBuilder();
        string connString = clsConnection.CommonConnString();
        int gblIntcount = 0;

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

        //--------------* Send Notification *-----------------------//
        public string SendNotification(MDLSendNotification mDLSendNotification)
        {
            string msg = "";
            try
            {
                var IsSent = false;
                int RecordId = 0;
                string FirebaseServerkey = commonMethods.GetFirebaseServerkey();
                DataTable FCMTokenList = CustomerHelper.GetFCMTokenListForApp(Convert.ToInt32(mDLSendNotification.TenantID));

                if (string.IsNullOrEmpty(mDLSendNotification.NotificationDate))
                {
                    DateTime time = DateTime.Now;
                    string format = "yyyy-MM-dd HH:mm:ss";
                    string NotificationDate = time.ToString(format);
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
                            IsSent = SendAppCustomNotification(FirebaseServerkey, Convert.ToString(FCMTokenList.Rows[IntI]["FCMToken"]), mDLSendNotification.NotificationTitle, mDLSendNotification.NotificationMessage, mDLSendNotification.NotificationDate, true);
                        }
                        FCMToken = Convert.ToString(FCMTokenList.Rows[IntI]["FCMToken"]);

                        if (tempTenantID != Convert.ToInt32(FCMTokenList.Rows[IntI]["TenantID"]))
                        {
                            CustomerHelper.AddAppCustomNotification_History(mDLSendNotification.Notification_Type, Convert.ToInt32(FCMTokenList.Rows[IntI]["TenantID"]), mDLSendNotification.NotificationTitle, mDLSendNotification.NotificationMessage, "", RecordId);
                        }
                        tempTenantID = Convert.ToInt32(FCMTokenList.Rows[IntI]["TenantID"]);
                    }
                }
                msg = "Successfully updated!";
            }
            catch
            {
                msg = "Something went wrong! Please contact to system admin!";
            }
            return msg;
        }

        public static bool SendAppCustomNotification(string key, string FCMToken, string Title, string Message, string NotificationDate, bool isScheduled = false)
        {
            var IsSent = false;
            try
            {
                string webAPI = "https://fcm.googleapis.com/fcm/send";

                var body = @"{
                        " + "\n" +
                            @"    ""to"": """ + FCMToken + @""",
                        " + "\n" +
                            @"    ""notification"": {
                        " + "\n" +
                            @"      ""title"": """ + Title + @""",
                        " + "\n" +
                            @"      ""body"": """ + Message + @""",
                        " + "\n" +
                            @"      ""isScheduled"" : """ + isScheduled + @""",
                        " + "\n" +
                            @"      ""scheduledTime"" : """ + NotificationDate + @"""
                        " + "\n" +
                            @"      }
                        " + "\n" +
                            @"}";
                var request = (HttpWebRequest)WebRequest.Create(webAPI);
                request.Headers.Add("Authorization", "key=" + key + "");

                var data = Encoding.ASCII.GetBytes(body.ToString());
                request.Method = "POST";
                request.ContentType = "application/json";
                using (var stream = request.GetRequestStream())
                {
                    stream.Write(data, 0, data.Length);
                }
                HttpWebResponse response = (HttpWebResponse)request.GetResponse();
                var responseString = new StreamReader(response.GetResponseStream()).ReadToEnd();
                IsSent = true;
            }
            catch (Exception)
            {
                IsSent = false;
            }

            return IsSent;
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

    }
}
