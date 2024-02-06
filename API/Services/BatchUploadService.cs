using Dapper;
using PartsConnectWebTools.Data;
using PartsConnectWebTools.Helpers;
using PartsConnectWebTools.Models.Custom;
using PCFitment_API.Models;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using TestRestAPI.Models.Utilities;

namespace PCFitment_API.Services
{
    public class BatchUploadService
    {
        StringBuilder stbSqlQuery = new StringBuilder();
        string connString = clsConnection.CommonConnString();
        int gblIntcount = 0;

        //--------------* Get Fitments Upload Details Start *-----------------------//

        public MDLGetFitmentsUploadDetails GetFitmentsUploadDetails(int tenantID)
        {
            MDLGetFitmentsUploadDetails mDLGetFitmentsUploadDetailsMain = new MDLGetFitmentsUploadDetails();

            bool isMulti = ValidateExcelHelper.CheckIsMultiBrandAccess(tenantID);
            DataTable dt = new DataTable();
            int Count = 0;

            if (isMulti == false)
            {
                //ViewBag.multi = true;
                dt = ValidateExcelHelper.GetBrandDetail(tenantID);
                if (dt.Rows.Count > 0)
                {
                    string brandaaiaid = Convert.ToString(dt.Rows[0]["BrandCode"]);
                    string brandDetails = Convert.ToString(dt.Rows[0]["BrandName"]);
                    mDLGetFitmentsUploadDetailsMain.BrandName = brandDetails + " (" + brandaaiaid + ")";
                }
            }

            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@" SELECT TOP(1) * FROM tools.userfiles WHERE ISNULL(validationtype,'Advance') = 'Advance' AND userid=@userid ORDER BY userfilesid DESC ");

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    command.Parameters.AddWithValue("@userid", tenantID);
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Count++;
                            MDLGetFitmentsUploadDetails mDLGetFitmentsUploadDetailsSub = new MDLGetFitmentsUploadDetails
                            {
                                checkunderprocess = reader["filestatus"] is DBNull ? string.Empty : reader["filestatus"].ToString(),
                                LastuploadfromUser = reader["filename"] is DBNull ? string.Empty : reader["filename"].ToString(),
                                usermakeRequestforadd = reader["flagAddFitment"] is DBNull ? string.Empty : reader["flagAddFitment"].ToString(),
                                UploadedTime = reader["createddate"] is DBNull ? string.Empty : reader["createddate"].ToString(),
                                ProcessingTime = commonMethods.getvalidationtime(Convert.ToInt32(reader["EstimatedTime"] is DBNull ? "0" : reader["EstimatedTime"].ToString())),
                                BrandID = reader["BrandID"] is DBNull ? string.Empty : reader["BrandID"].ToString(),
                                ValidFitment = reader["validapplication"] is DBNull ? string.Empty : reader["validapplication"].ToString(),
                                ValidPartType = reader["ValidPartType"] is DBNull ? string.Empty : reader["ValidPartType"].ToString(),
                                ValidPartNumber = reader["ValidPartNumber"] is DBNull ? string.Empty : reader["ValidPartNumber"].ToString(),
                                InvalidFitment = reader["invalidapplication"] is DBNull ? string.Empty : reader["invalidapplication"].ToString(),
                                InvalidPartType = reader["InvalidPartType"] is DBNull ? string.Empty : reader["InvalidPartType"].ToString(),
                                InvalidPartNumber = reader["InvalidPartNumber"] is DBNull ? string.Empty : reader["InvalidPartNumber"].ToString(),
                                reason = reader["reason"] is DBNull ? string.Empty : reader["reason"].ToString(),
                                BLisFitmentAdded = reader["AddFitmentProcessCompleted"] is DBNull ? string.Empty : reader["AddFitmentProcessCompleted"].ToString()
                            };
                            mDLGetFitmentsUploadDetailsMain = mDLGetFitmentsUploadDetailsSub;
                        }

                    }
                }
                connection.Close();
            }

            if (Count <= 0)
            {
                mDLGetFitmentsUploadDetailsMain.LastuploadfromUser = "";
            }
            else
            {
                if (!string.IsNullOrWhiteSpace(mDLGetFitmentsUploadDetailsMain.BrandID))
                {
                    dt = ValidateExcelHelper.GetBrandDetail(tenantID, mDLGetFitmentsUploadDetailsMain.BrandID);
                    if (dt.Rows.Count > 0)
                    {
                        string brandaaiaid = Convert.ToString(dt.Rows[0]["BrandCode"]);
                        string brandDetails = Convert.ToString(dt.Rows[0]["BrandName"]);
                        mDLGetFitmentsUploadDetailsMain.BrandName = brandDetails + " (" + brandaaiaid + ")";
                    }
                }
            }
            if (mDLGetFitmentsUploadDetailsMain.checkunderprocess == "D" || mDLGetFitmentsUploadDetailsMain.checkunderprocess == "F")
            {
                if (Convert.ToBoolean(mDLGetFitmentsUploadDetailsMain.usermakeRequestforadd) == true)
                {
                    mDLGetFitmentsUploadDetailsMain.isFitmentAddRequstMade = true;
                    mDLGetFitmentsUploadDetailsMain.isFitmentAdded = Convert.ToBoolean(mDLGetFitmentsUploadDetailsMain.BLisFitmentAdded) == true ? "Added" : "processing";
                    string AddStatus = ValidateExcelHelper.GetLastAddedFileUserInfo(tenantID);
                    if (AddStatus == "Error")
                    {
                        mDLGetFitmentsUploadDetailsMain.TechnicalError = AddStatus;
                    }
                    else
                    {
                        DataTable dtrerresult = ValidateExcelHelper.GetLasstUploadedFileDetails(tenantID);
                        int new_aces = 0; int new_part = 0;
                        if (dtrerresult != null && dtrerresult.Rows.Count > 0)
                        {
                            new_aces = Convert.ToInt32(dtrerresult.Rows[0]["NewFitmentCount"].ToString());
                            new_part = Convert.ToInt32(dtrerresult.Rows[0]["NewPartCount"].ToString());
                        }
                        mDLGetFitmentsUploadDetailsMain.NewACES = new_aces;
                        mDLGetFitmentsUploadDetailsMain.NewPart = new_part;
                    }
                }
                else
                {
                    mDLGetFitmentsUploadDetailsMain.TechnicalError = mDLGetFitmentsUploadDetailsMain.reason;
                }
            }
            else if (mDLGetFitmentsUploadDetailsMain.checkunderprocess == "E")
            {
                mDLGetFitmentsUploadDetailsMain.TechnicalError = "Error";
            }

            if (Convert.ToBoolean(mDLGetFitmentsUploadDetailsMain.usermakeRequestforadd) != true)
            {
                mDLGetFitmentsUploadDetailsMain.IsMakeReq = "Not Requested";
            }
            else
            {
                mDLGetFitmentsUploadDetailsMain.IsMakeReq = "Requested";
            }


            return mDLGetFitmentsUploadDetailsMain;
        }

        public IEnumerable<MDLGetFitmentsLastUploadedFiles> GetFitmentsLastUploadedFiles(int tenantID)
        {
            IEnumerable<MDLGetFitmentsLastUploadedFiles> mDLGetFitments;
            StringBuilder stbSqlQuery = new StringBuilder();

            using (var conn = new SqlConnection(clsConnection.CommonConnString()))
            {
                conn.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@" SELECT TOP (5)
                                        *,
                                        CASE
                                          WHEN
                                            flagAddFitment = 0 AND
                                            ValidPartType > 0 AND
                                            ValidPartNumber > 0 AND
                                            AddFitmentProcessCompleted > 1 AND
                                            [filestatus] = 'D' THEN 'Yes'
                                          ELSE 'No'
                                        END AS 'IsAddData'
                                      FROM tools.userfiles
                                      WHERE userid = @TenantID
                                      ORDER BY createddate DESC ");
                mDLGetFitments = conn.Query<MDLGetFitmentsLastUploadedFiles>(stbSqlQuery.ToString(), new { TenantID = tenantID }).ToList();

                conn.Close();
            }

            return mDLGetFitments;
        }

        //--------------* Post Method Add (Fitment) Data Start *-----------------------//
        public string AddFitments(int userfilesid, int tenantID)
        {
            string msgCode = "S";

            dynamic Userdata = ValidateExcelHelper.GetLastuploadinfooftheUser(userfilesid, tenantID);
            if (Userdata != null)
            {
                string export_excel = Userdata[0].export_excel;
                if (!string.IsNullOrEmpty(export_excel))
                {
                    ValidateExcelHelper.InsertRecordsAddFitmentRequest(tenantID, export_excel, Userdata[0].userfilesid);
                    msgCode = "S";
                    //msg = "Your data has been added to your PCFitment Account.";
                }
                else
                {
                    msgCode = "F";
                    //msg = "Something went wrong! Please contact to system admin!";
                }
            }

            return msgCode;
        }

    }
}
