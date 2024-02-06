using PCFitment_API.Models;
using System.Data.SqlClient;
using System.Security.Claims;
using System.Text;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;
using Microsoft.AspNetCore.Mvc;
using PartsConnectWebTools.Helpers;
using PartsConnectWebTools.Models.Custom;
using System.Data;
using Microsoft.AspNetCore.Hosting.Server;
using Newtonsoft.Json.Linq;
using System.Net;
using System.Collections;
using System.Web;
using Microsoft.AspNetCore.Http;
using Dapper;

namespace TestRestAPI.Models.Utilities
{
    public class clsConnection
    {
        public static string CommonConnString()
        {
            var configuration = commonMethods.GetConfiguration();
            SqlConnection sqlConn = new SqlConnection(configuration.GetSection("ConnectionStrings").GetSection("DefaultConnection").Value);
            return sqlConn.ConnectionString.ToString();
        }

    }
    public class commonMethods
    {
        //Root Path
        public static string RootPath()
        {
            var configuration = GetConfiguration();
            string rootPath = Convert.ToString(configuration.GetSection("RootPath").GetSection("DefaultRootPath").Value);
            return rootPath;
        }
        //Recent Exported File Download
        public static string RecentExportedFileDownload()
        {
            var configuration = GetConfiguration();
            string RecentExportedFileDownload = Convert.ToString(configuration.GetSection("RecentExportedFileDownload").GetSection("DefaultRecentExportedFileDownload").Value);
            return RecentExportedFileDownload;
        }
        //Physical Path
        public static string PhysicalPath()
        {
            var configuration = GetConfiguration();
            string physicalPath = Convert.ToString(configuration.GetSection("PhysicalPath").GetSection("DefaultPhysicalPath").Value);
            return physicalPath;
        }
        //Invoice Static File
        public static string GetInvoiceStaticFile()
        {
            var configuration = GetConfiguration();
            string InvoiceStaticFile = Convert.ToString(configuration.GetSection("InvoiceStaticFile").GetSection("DefaultInvoiceStaticFile").Value);
            return InvoiceStaticFile;
        }
        //Stripe Secret Key
        public static string GetStripeSecretKey()
        {
            var configuration = GetConfiguration();
            string StripeSecretKey = Convert.ToString(configuration.GetSection("StripeSecretKey").GetSection("DefaultStripeSecretKey").Value);
            return StripeSecretKey;
        }
        //Firebase Server Key
        public static string GetFirebaseServerkey()
        {
            var configuration = GetConfiguration();
            string FirebaseServerkey = Convert.ToString(configuration.GetSection("FirebaseServerkey").GetSection("DefaultFirebaseServerkey").Value);
            return FirebaseServerkey;
        }

        //Ebay Login Req time
        public static string GetEbayLoginReqtime()
        {
            var configuration = GetConfiguration();
            string EbayLoginReqtime = Convert.ToString(configuration.GetSection("EbayLoginReqtime").GetSection("DefaultEbayLoginReqtime").Value);
            return EbayLoginReqtime;
        }
        public static IConfigurationRoot GetConfiguration()
        {
            var builder = new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory()).AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);
            return builder.Build();
        }
        //Password Encrypt/Decrypt Logic
        public static string DecryptPassword(string password)
        {
            string strpass = "";
            System.Security.Cryptography.SHA1 hash = System.Security.Cryptography.SHA1.Create();
            System.Text.ASCIIEncoding encoder = new System.Text.ASCIIEncoding();
            byte[] combined = encoder.GetBytes(password);
            hash.ComputeHash(combined);
            strpass = Convert.ToBase64String(hash.Hash);
            return strpass;
        }
        public static bool IsAdmin(string id)
        {
            bool IsAdmin = false;
            var configuration = GetConfiguration();
            string[] ArrAdmin = Convert.ToString(configuration.GetSection("Free_Acc").GetSection("DefaultFree_Acc").Value).Split(',');

            if (ArrAdmin.Length > 0)
            {
                for (int i = 0; i < ArrAdmin.Length; i++)
                {
                    if (id == ArrAdmin[i].ToString().Trim())
                    {
                        IsAdmin = true;
                    }
                }
            }

            return IsAdmin;
        }
        public static int PageSize()
        {
            var configuration = GetConfiguration();
            int PageSize = Convert.ToInt32(configuration.GetSection("PageSize").GetSection("DefaultPageSize").Value);
            return PageSize;
        }
        public static bool IsCustomFitmentsAccess(int TenantID)
        {
            try
            {
                DataTable dt = new DataTable();
                dt = TenantsDetails(TenantID);

                if (dt.Rows.Count > 0)
                {
                    string IsCustomFitments = dt.Rows[0]["IsCustomFitmentsAccess"].ToString();

                    return Convert.ToBoolean(IsCustomFitments);
                }
                else
                {
                    return false;
                }
            }
            catch (Exception ex)
            {
                return false;
            }
        }
        public static bool IsBrandShowMenu(int TenantID)
        {
            bool IsShow = false;
            try
            {
                DataTable dt = new DataTable();
                dt = TenantsDetails(TenantID);
                PaymentDetail paymentDetail = new PaymentDetail();
                paymentDetail = TenantsSubscriptionHelper.GetLastPaymentOfUser(TenantID);
                if (Convert.ToInt32(paymentDetail.BillingAmount) >= 25)
                {
                    IsShow = true;
                }
                else
                {
                    string IsMultiBrand = "";
                    if (dt.Rows.Count > 0)
                    {
                        IsMultiBrand = dt.Rows[0]["IsMultiBrandAccess"].ToString();
                        IsShow = Convert.ToBoolean(IsMultiBrand);
                    }
                }
                return IsShow;
            }
            catch (Exception ex)
            {
                return false;
            }
        }
        public static DataTable TenantsDetails(int tenantID)
        {
            DataTable dt = new DataTable();
            StringBuilder stbSqlQuery = new StringBuilder();
            using (SqlConnection connection = new SqlConnection(clsConnection.CommonConnString()))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@" SELECT * FROM [tools].[Tenants] WHERE ID = '" + tenantID + "';");

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    using (SqlDataAdapter SDA = new SqlDataAdapter(command))
                    {
                        SDA.Fill(dt);
                    }
                }
                connection.Close();
            }

            return dt;
        }
        public static string getvalidationtime(int time)
        {
            string validationtime = "";
            if (time > 60)
            {
                int h = time / 60;
                int m = time % 60;
                validationtime = h + " hr " + m + " min";
            }
            else
            {
                validationtime = time + " min";
            }
            return validationtime;
        }
        public static int Submitlimit()
        {
            var configuration = GetConfiguration();
            int Submitlimit = Convert.ToInt32(configuration.GetSection("Submitlimit").GetSection("DefaultSubmitlimit").Value);
            return Submitlimit;
        }
        public static string BrandVerificationBufferDays()
        {
            var configuration = GetConfiguration();
            string BrandVerificationBufferDays = Convert.ToString(configuration.GetSection("BrandVerificationBufferDays").GetSection("DefaultBrandVerificationBufferDays").Value);
            return BrandVerificationBufferDays;
        }
        public static bool IsEbayUser()
        {
            //bool Isebayuser = false;
            //int TenantID = UserHelper.GetTenantID();
            //if (TenantID > 0)
            //{
            //    string[] TenantIDs = ConfigurationManager.AppSettings["EbayUser"].Split(',');
            //    //Check is user enable for overlap validation
            //    Isebayuser = CustomerHelper.CheckIDs(TenantIDs, TenantID);
            //}
            //return Isebayuser;
            /*
            try
            {
                string IseBayAccess = ClaimsPrincipal.Current.FindFirst("IseBayAccess").Value;
                return Convert.ToBoolean(IseBayAccess);     
            }
            catch (Exception ex)
            {
                return false;
            }
            */
            return true;
        }
        public static void getsetEbaytokenforUser(out string message,out string EbayloginMsg, int tenantID)
        {
            string tempmessage = "";
            string loginMsg = "";
            string CheckeBayToken = CustomerHelper.CheckeBayToken(tenantID);
            if (CheckeBayToken == "users_token_expired")
            {
                string refresh_token = CustomerHelper.getSingleValueFromTenants(tenantID, "refresh_token");
                GetSeteBay(tenantID, refresh_token, "", "refresh_token");
                CheckeBayToken = CustomerHelper.CheckeBayToken(tenantID);
            }
            else if (CheckeBayToken == "refresh_token_expired")
            {
                if (!string.IsNullOrEmpty(CustomerHelper.getSingleValueFromTenants(tenantID, "refresh_token_expires_Date")))
                {
                    loginMsg = "Your eBay access token has been expired, Please login and give us an access.";
                }
                else
                {
                    //loginMsg = "We don't have your eBay account access, so can you please log on and give us an access for eBay fitment.";
                    loginMsg = "You have to give access to your eBay account before add eBay part or fitment.";
                }
                tempmessage = "Yes";
            }
            if (CheckeBayToken == "GoAhead")
            {
                tempmessage = "GoAhead";
            }

            EbayloginMsg = loginMsg;
            message = tempmessage;
        }
        public static string GetSeteBay(int tenantID, string code, string expires_in, string Types)
        {
            CustomerHelper objcust = new CustomerHelper();
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(GetSettingValue("APIUL"));

            //Add the request headers
            //-------------------------------------------------------------------------
            //Add the keys
            request.Headers.Add("Authorization", "Basic " + GetSettingValue("B64OAUTH"));
            String RequestBody = "";
            if (Types == "refresh_token")
                RequestBody = "grant_type=refresh_token&refresh_token=" + WebUtility.UrlEncode(code) + "&scope=" + WebUtility.UrlEncode("https://api.ebay.com/oauth/api_scope");
            else
                RequestBody = "grant_type=authorization_code&code=" + WebUtility.UrlEncode(code) + "&redirect_uri=" + GetSettingValue("RUNAM") + "&scope=" + WebUtility.UrlEncode("https://api.ebay.com/oauth/api_scope");

            //Set the request properties
            request.Method = "POST";
            request.ContentType = "application/x-www-form-urlencoded";
            //-------------------------------------------------------------------------

            //Put the data into a UTF8 encoded  byte array
            UTF8Encoding encoding = new UTF8Encoding();
            int dataLen = encoding.GetByteCount(RequestBody);

            byte[] utf8Bytes = new byte[dataLen];
            Encoding.UTF8.GetBytes(RequestBody, 0, RequestBody.Length, utf8Bytes, 0);

            Stream str = null;
            try
            {
                //Set the request Stream

                str = request.GetRequestStream();

                //Write the request to the Request Steam
                str.Write(utf8Bytes, 0, utf8Bytes.Length);

                str.Close();

                //Get response into stream
                WebResponse response = request.GetResponse();

                str = response.GetResponseStream();

                // Get Response into String
                StreamReader sr = new StreamReader(str);
                string result = sr.ReadToEnd();

                if (!string.IsNullOrEmpty(result))
                {
                    JObject json = JObject.Parse(result);
                    //code to update expiry date and token
                    CustomerHelper.updateEbaytoken(tenantID, Convert.ToString(json.GetValue("access_token")), DateTime.Now.AddSeconds(Convert.ToInt32(json.GetValue("expires_in").ToString())), Convert.ToString(json.GetValue("refresh_token")), DateTime.Now.AddSeconds(Convert.ToInt32(json.GetValue("refresh_token_expires_in"))), Types);
                }
                sr.Close();
                str.Close();
            }
            catch (Exception Ex)
            {
                //HttpContext.Current.Session["eBayEx"] = Ex.Message.ToString();
            }
            return "";
        }
        public static string GetSettingValue(string strKey)
        {
            string strValue = "";

            System.Collections.Hashtable dt = GetSetting();
            if (Convert.ToString(dt[strKey]) != "")
            {
                strValue = Convert.ToString(dt[strKey]);
            }

            return strValue;
        }
        public static Hashtable GetSetting()
        {
            Hashtable Hdtsetting = new Hashtable();
            System.Data.DataTable dtSetting = new System.Data.DataTable();
            string strQuery = "Select * from [tools].[generalsettings]";
            SqlConnection objConn = new SqlConnection(clsConnection.CommonConnString());
            SqlDataAdapter objAdapt = new SqlDataAdapter(strQuery, objConn);
            objAdapt.SelectCommand.CommandTimeout = 0;
            objAdapt.Fill(dtSetting);

            if (dtSetting.Rows.Count > 0)
            {
                for (int s = 0; s < dtSetting.Rows.Count; s++)
                {
                    Hdtsetting.Add(Convert.ToString(dtSetting.Rows[s]["strkey"]), Convert.ToString(dtSetting.Rows[s]["strvalue"]));
                }
            }

            return Hdtsetting;
        }
        //App Name
        public static string Getappname()
        {
            var configuration = GetConfiguration();
            string appname = Convert.ToString(configuration.GetSection("appname").GetSection("Defaultappname").Value);
            return appname;
        }
        //App URL
        public static string Getafitmenturl()
        {
            var configuration = GetConfiguration();
            string afitmenturl = Convert.ToString(configuration.GetSection("afitmenturl").GetSection("Defaultafitmenturl").Value);
            return afitmenturl;
        }
        //eBayErrorMsg
        public static string GeteBayErrorMsg()
        {
            var configuration = GetConfiguration();
            string eBayErrorMsg = Convert.ToString(configuration.GetSection("eBayErrorMsg").GetSection("DefaulteBayErrorMsg").Value);
            return eBayErrorMsg;
        }
        public static string GetTermsAndConditionUrl()
        {
            var configuration = GetConfiguration();
            string termsandconditionurl = Convert.ToString(configuration.GetSection("termsandconditionurl").GetSection("Defaulttermsandconditionurl").Value);
            return termsandconditionurl;
        }
        public static string GetPrivacyAndPolicyUrl()
        {
            var configuration = GetConfiguration();
            string privacyandpolicyurl = Convert.ToString(configuration.GetSection("privacyandpolicyurl").GetSection("Defaultprivacyandpolicyurl").Value);
            return privacyandpolicyurl;
        }

        public static bool IsTermsAndConditionAccept(string PRDeviceID, bool PRIsTermsAndConditionAccept)
        {
            bool LCLIsTermsAndConditionAccept = false;
            if (!PRIsTermsAndConditionAccept)
            {
                string Query = " SELECT COUNT(*) FROM [dbo].[App_Settings] WHERE DeviceID = @DeviceID AND IsTermsAndConditionAccept = 1 ";
                int Count = 0;
                using (var conn = new SqlConnection(clsConnection.CommonConnString()))
                {
                    conn.Open();
                    Count = conn.Query<int>(Query, new { DeviceID = PRDeviceID }).FirstOrDefault();
                    conn.Close();
                }

                if (Count > 0)
                {
                    LCLIsTermsAndConditionAccept = true;
                }
            }
            else
            {
                LCLIsTermsAndConditionAccept = PRIsTermsAndConditionAccept;
            }

            return LCLIsTermsAndConditionAccept;
        }

        public static bool IsPrivacyPolicyAccept(string PRDeviceID, bool PRIsPrivacyPolicyAccept)
        {
            bool LCLIsPrivacyPolicyAccept = false;
            if (!PRIsPrivacyPolicyAccept)
            {
                string Query = " SELECT COUNT(*) FROM [dbo].[App_Settings] WHERE DeviceID = @DeviceID AND IsPrivacyPolicyAccept = 1 ";
                int Count = 0;
                using (var conn = new SqlConnection(clsConnection.CommonConnString()))
                {
                    conn.Open();
                    Count = conn.Query<int>(Query, new { DeviceID = PRDeviceID }).FirstOrDefault();
                    conn.Close();
                }

                if (Count > 0)
                {
                    LCLIsPrivacyPolicyAccept = true;
                }
            }
            else
            {
                LCLIsPrivacyPolicyAccept = PRIsPrivacyPolicyAccept;
            }

            return LCLIsPrivacyPolicyAccept;
        }

    }

    public class Messages
    {
        //Common
        public const string CON_Login_Success = "Login Successfully!";
        public const string CON_Login_Invalid = "Invalid Credential!";
        public const string CON_Success = "Operation Completed Successfully!";
        public const string CON_Edit_Data = "Data Updated Successfully!";
        public const string CON_Logout_Success = "Logout Successfully!";
        public const string CON_Valid_Customer_Id = "Please Provide Valid Customer Id!";
        public const string CON_No_Data_Found = "No Records Found!";
        public const string CON_No_Files_Found = "No Files Found!";
        public const string CON_Help_Videos = "Fetched Successfully!";
        public const string CON_Notification = "Notification Sent Successfully!";
    }

}