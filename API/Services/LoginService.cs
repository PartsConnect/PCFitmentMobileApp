using Dapper;
using PartsConnectWebTools.Models.Custom;
using PCFitment_API.IService;
using PCFitment_API.Models;
using System.Data.SqlClient;
using System.Net.NetworkInformation;
using System.Text;
using TestRestAPI.Models.Utilities;
using static System.Runtime.CompilerServices.RuntimeHelpers;

namespace PCFitment_API.Services
{
    public class LoginService : ILoginService
    {
        public string connectionString = clsConnection.CommonConnString();
        StringBuilder stbSqlCommand = new StringBuilder();

        //-------------------------------------//

        #region Start Authentication Query
        public string AuthenticateTenant(Login tenant)
        {
            string mstrtenantID = "0", mstrtenantName = "";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                stbSqlCommand.Clear();
                stbSqlCommand.Append("SELECT ID,(FirstName + ' ' + LastName) AS FullName FROM [tools].[Tenants] where Email ='" + tenant.Email + "'COLLATE Latin1_General_CS_AS AND [password] = '" + commonMethods.DecryptPassword(tenant.Password) + "'COLLATE Latin1_General_CS_AS");

                using (SqlCommand command = new SqlCommand(stbSqlCommand.ToString(), connection))
                {
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            mstrtenantID = (reader["ID"].ToString());
                            mstrtenantName = (reader["FullName"].ToString());
                        }
                    }
                }
                connection.Close();
            }

            return mstrtenantID + "~" + mstrtenantName;
        }

        public int SaveFCMToken(int PRtenantId, string PRFCMToken = "", string PRDeviceID = "", string PRIsTermsAndConditionAccept = "0", string PRIsPrivacyPolicyAccept = "0")
        {
            if (!IsFCMTokenExists(PRtenantId, PRDeviceID))
            {
                int InsertedID = 0;
                string Query = @" INSERT INTO [dbo].[App_Settings] (TenantID, FCMToken, DeviceID, IsTermsAndConditionAccept, IsPrivacyPolicyAccept) VALUES (@TenantID, @FCMToken, @DeviceID, @IsTermsAndConditionAccept, @IsPrivacyPolicyAccept) 
                                  SELECT CAST(SCOPE_IDENTITY() as int)";
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    InsertedID = conn.Query<int>(Query, new
                    {
                        TenantID = PRtenantId,
                        FCMToken = PRFCMToken,
                        DeviceID = PRDeviceID,
                        IsTermsAndConditionAccept = commonMethods.IsTermsAndConditionAccept(PRDeviceID, Convert.ToBoolean(PRIsTermsAndConditionAccept)),
                        IsPrivacyPolicyAccept = commonMethods.IsPrivacyPolicyAccept(PRDeviceID, Convert.ToBoolean(PRIsPrivacyPolicyAccept))
                    }).FirstOrDefault();
                    conn.Close();
                }
                return InsertedID;
            }
            else
            {
                try
                {
                    string Query = @" UPDATE [dbo].[App_Settings] SET FCMToken = @FCMToken, ISActive = 0, IsTermsAndConditionAccept = @IsTermsAndConditionAccept, IsPrivacyPolicyAccept = @IsPrivacyPolicyAccept WHERE TenantID = @TenantID AND DeviceID = @DeviceID ;";
                    using (var conn = new SqlConnection(connectionString))
                    {
                        conn.Open();
                        conn.Query(Query, new
                        {
                            TenantID = PRtenantId,
                            FCMToken = PRFCMToken,
                            DeviceID = PRDeviceID,
                            IsTermsAndConditionAccept = commonMethods.IsTermsAndConditionAccept(PRDeviceID,Convert.ToBoolean(PRIsTermsAndConditionAccept)),
                            IsPrivacyPolicyAccept = commonMethods.IsPrivacyPolicyAccept(PRDeviceID, Convert.ToBoolean(PRIsPrivacyPolicyAccept))
                        });
                        conn.Close();
                    }
                    return 1;
                }
                catch (Exception)
                {
                    return 0;
                }
            }
        }

        public bool IsFCMTokenExists(int PRtenantId, string PRDeviceID)
        {
            string Query = " SELECT COUNT(*) FROM [dbo].[App_Settings] WHERE TenantID = @TenantID AND DeviceID = @DeviceID";
            int Count = 0;
            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                Count = conn.Query<int>(Query, new { TenantID = PRtenantId, DeviceID = PRDeviceID }).FirstOrDefault();
                conn.Close();
            }
            if (Count > 0)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        #endregion End Authentication Query

        //-------------------------------------//

    }
}
