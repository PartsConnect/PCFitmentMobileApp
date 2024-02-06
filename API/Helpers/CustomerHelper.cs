using System.Data.SqlClient;
using System.Data;
using TestRestAPI.Models.Utilities;
using Dapper;

namespace PartsConnectWebTools.Helpers
{
    public class CustomerHelper
    {
        private static string myConnectionString = clsConnection.CommonConnString();
        public CustomerHelper()
        {

        }

        public static DataTable GetFCMTokenListForApp(int TenantID)
        {
            DataTable user = new DataTable();
            string Query = @" SELECT FCMToken,TenantID FROM [dbo].[App_Settings] WHERE ISActive = 1 ";
            if (TenantID > 0)
            {
                Query += @" AND TenantID = @TenantID";
            }
            Query += @" Order By FCMToken, TenantID";

            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                SqlDataAdapter da = new SqlDataAdapter(Query, conn);
                if (TenantID > 0)
                {
                    da.SelectCommand.Parameters.AddWithValue("@TenantID", TenantID);
                }
                da.Fill(user);
                conn.Close();
            }

            return user;

        }

        public static int AddAppCustomNotification_History(string Notification_Type, int TenantID, string NotificationTitle, string NotificationMessage, string LinkPage, int ReferenceId)
        {
            string Query = "";
            int InsertedId = 0;


            if (Convert.ToInt32(TenantID) > 0)
            {
                Query = @"if not exists(SELECT  * from [dbo].[App_Notification_History] 
                                        where Notification_Type = @Notification_Type 
                                        and TenantID = @TenantID 
                                        and NotificationTitle = @NotificationTitle 
                                        and NotificationMessage = @NotificationMessage
                                        and ReferenceId = @ReferenceId  and IsNotificationSent = @IsNotificationSent
                                            ) 
 
                                            begin


                                            INSERT INTO [dbo].[App_Notification_History]
                                                                           ([Notification_Type]
                                                                           ,[TenantID]
                                                                           ,[NotificationTitle]
                                                                           ,[NotificationMessage]
                                                                           ,[LinkPage]
                                                                           ,[IsNotificationSent]
                                                                           ,[Flagdeleted]
                                                                           ,[ReferenceId])
                                                                     VALUES
                                                                           (@Notification_Type 
                                                                           ,@TenantID 
                                                                           ,@NotificationTitle 
                                                                           ,@NotificationMessage 
                                                                           ,@LinkPage 
                                                                           ,@IsNotificationSent 
                                                                           ,@Flagdeleted 
                                                                           ,@ReferenceId ); SELECT SCOPE_IDENTITY() ;

                                            END";
                using (var conn = new SqlConnection(myConnectionString))
                {
                    conn.Open();
                    conn.Query(Query, new
                    {
                        Notification_Type = Notification_Type,
                        TenantID = TenantID,
                        NotificationTitle = NotificationTitle,
                        NotificationMessage = NotificationMessage,
                        LinkPage = LinkPage,
                        IsNotificationSent = "1",
                        Flagdeleted = "0",
                        ReferenceId = ReferenceId
                    });
                    conn.Close();
                }
            }

            return InsertedId;
        }

        public static int AddAppCustomNotification(string tTitle, string tMessage, string tMessageDate, int TenantID)
        {
            string Query = "";
            int InsertedId = 0;

            Query = @"INSERT INTO [dbo].[App_Custom_Notification]
                               ([Title]
                               ,[Message]
                               ,[MessageDate]
                               ,[TenantID])
                         VALUES
                               ( @Title
                                ,@Message
                                ,@MessageDate
                                ,@TenantID); SELECT SCOPE_IDENTITY() ;";

            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(Query, conn);
                cmd.Parameters.AddWithValue("@Title", tTitle);
                cmd.Parameters.AddWithValue("@Message", tMessage);
                cmd.Parameters.AddWithValue("@MessageDate", tMessageDate);
                cmd.Parameters.AddWithValue("@TenantID", TenantID);

                var ttextcontentid = cmd.ExecuteScalar();
                InsertedId = Convert.ToInt32(ttextcontentid);
                conn.Close();
            }
            return InsertedId;


        }
        public static string CheckeBayToken(int tenantID)
        {
            string CheckeBayToken = "";
            string Query = @"SELECT Case when Datediff(Minute,getdate(), ISNULL(ebaytokendate,getdate())) <= 1 then Case when Datediff(Minute,getdate(), ISNULL(refresh_token_expires_Date,getdate()))  <= 1 then 'refresh_token_expired' else 'users_token_expired' end else 'GoAhead' end  as CheckeBayToken FROM tools.Tenants WHERE ID=@TenantID";
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                CheckeBayToken = conn.Query<string>(Query, new { TenantID = tenantID }).FirstOrDefault();
                conn.Close();
            }
            return CheckeBayToken;
        }
        public static string getSingleValueFromTenants(int tenantID, String ColumnName)
        {
            string token = "";
            string Query = @"SELECT " + ColumnName + " FROM tools.Tenants WHERE ID=@TenantID";
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                token = conn.Query<string>(Query, new { TenantID = tenantID }).FirstOrDefault();
                conn.Close();
            }
            return token;
        }
        public static void updateEbaytoken(int tenantid, string ebaytoken, DateTime ebaytokendate, string refresh_token, DateTime refresh_token_expires_Date, string Types)
        {
            string Query = "";
            if (Types == "refresh_token")
                Query = @"UPDATE tools.Tenants SET ebaytoken='" + ebaytoken + "',ebaytokendate='" + ebaytokendate + "',isebaytokenexpired = 0 WHERE ID=@TenantID ";
            else
                Query = @"UPDATE tools.Tenants SET ebaytoken='" + ebaytoken + "',ebaytokendate='" + ebaytokendate + "',isebaytokenexpired = 0,refresh_token='" + refresh_token + "',refresh_token_expires_Date='" + refresh_token_expires_Date + "' WHERE ID=@TenantID ";
            //HttpContext.Current.Session["eBayUpdateQuery"] = Query;
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                conn.Query(Query, new { TenantID = tenantid });
                conn.Close();
            }
        }

    }
}