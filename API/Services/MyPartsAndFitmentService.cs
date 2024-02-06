using Microsoft.Extensions.Configuration.UserSecrets;
using Microsoft.IdentityModel.Tokens;
using PartsConnectWebTools.Helpers;
using PCFitment_API.IService;
using PCFitment_API.Models;
using System.Collections;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Numerics;
using System.Reflection.PortableExecutable;
using System.Runtime.CompilerServices;
using System.Runtime.Intrinsics.Arm;
using System.Text;
using TestRestAPI.Models.Utilities;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

namespace PCFitment_API.Services
{
    public class MyPartsAndFitmentService
    {
        StringBuilder stbSqlQuery = new StringBuilder();
        string connString = clsConnection.CommonConnString();

        //----------------* My Parts & Fitment *---------------------//
        public object GetMyPartsAndFitmentList(int tenantID, int item, string searchValue, int IMPageSize, int IMpageNumber, bool IsCount = false)
        {
            MDLGetMyPartsAndFitmentInfo getMyPartsAndFitmentInfoMain = new MDLGetMyPartsAndFitmentInfo();
            int totalRecordCount = 0;

            string tablename = "tools.Parts_" + tenantID;
            string fitmentTable = "tools.FitmentsSaved_" + tenantID;
            string Query = "";

            CustomQueryBuillder.AddUniversalCollectionColumns(tenantID);
            Query = CustomQueryBuillder.BuildQueryForParts(item, tenantID, tablename, fitmentTable, IMpageNumber, IMPageSize, searchValue, IsCount);
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(Query);

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (!IsCount)
                        {
                            while (reader.Read())
                            {
                                MDLGetMyPartsAndFitment getMyPartsAndFitmentSub = new MDLGetMyPartsAndFitment
                                {
                                    ID = reader["ID"] is DBNull ? string.Empty : reader["ID"].ToString(),
                                    TenantID = reader["TenantID"] is DBNull ? string.Empty : reader["TenantID"].ToString(),
                                    PartTypeName = reader["PartTypeName"] is DBNull ? string.Empty : reader["PartTypeName"].ToString(),
                                    PartNumber = reader["PartNumber"] is DBNull ? string.Empty : reader["PartNumber"].ToString(),
                                    ASIN = reader["ASIN"] is DBNull ? string.Empty : reader["ASIN"].ToString(),
                                    BrandID = reader["BrandID"] is DBNull ? string.Empty : reader["BrandID"].ToString(),
                                    ManufactureLabel = reader["ManufactureLabel"] is DBNull ? string.Empty : reader["ManufactureLabel"].ToString(),
                                    PartDescription = reader["PartDescription"] is DBNull ? string.Empty : reader["PartDescription"].ToString(),
                                    PartTerminologyID = reader["PartTerminologyID"] is DBNull ? string.Empty : reader["PartTerminologyID"].ToString(),
                                    CollectionID = reader["collectionId"] is DBNull ? string.Empty : reader["collectionId"].ToString(),
                                    IsAmazonFit = reader["IsAmazonFit"] is DBNull ? string.Empty : reader["IsAmazonFit"].ToString(),
                                    Fitmentsnum = Convert.ToString(MGetAllCount(tenantID, reader["ID"] is DBNull ? string.Empty : reader["ID"].ToString())),
                                    SavedFitmentsCount = Convert.ToString(MGetSavedFitmentsCount(tenantID, reader["ID"] is DBNull ? string.Empty : reader["ID"].ToString())),
                                    ErrorFitmentsCount = Convert.ToString(MGetErrorFitmentsCount(tenantID, reader["ID"] is DBNull ? string.Empty : reader["ID"].ToString()))
                                };
                                getMyPartsAndFitmentInfoMain.MyPartsAndFitmentList.Add(getMyPartsAndFitmentSub);
                            }
                        }
                        else
                        {
                            DataTable dt = new DataTable();
                            dt.Load(reader);
                            totalRecordCount = dt.Rows.Count;
                        }
                    }
                }
                connection.Close();
            }
            if (!IsCount)
            {
                return getMyPartsAndFitmentInfoMain;
            }
            else
            {
                return totalRecordCount;
            }
        }

        public object GetSavedFitments(int tenantID, int IMPageSize, int IMpageNumber, bool IsCount = false, int partID = 0, string yearsearch = "", string makesearch ="", string modelsearch = "")
        {
            IEnumerable<MDLGetSavedFitments> getSavedFitmentsInfoMain;
            int totalRecordCount = 0;
            CustomQueryBuillder.AddUniversalCollectionColumns(tenantID);
            string where = string.Empty;

            if (!string.IsNullOrEmpty(yearsearch))
            {
                where = "AND YEAR LIKE '%"+ yearsearch + "%'";
            }
            if (!string.IsNullOrEmpty(makesearch))
            {
                where += "AND Make LIKE '%" + makesearch + "%'";
            }
            if (!string.IsNullOrEmpty(modelsearch))
            {
                where += "AND Model LIKE '%" + modelsearch + "%'";
            }
            
            getSavedFitmentsInfoMain = PartsHelper.GetSavedFitment(tenantID, partID, IMpageNumber, IMPageSize, where, "");

            if (!IsCount)
            {
                return getSavedFitmentsInfoMain;
            }
            else
            {
                foreach (var item in getSavedFitmentsInfoMain)
                {
                    totalRecordCount = item.Total;
                    if (totalRecordCount > 0)
                    {
                        break;
                    }
                }
                return totalRecordCount;
            }
        }

        public object GetErrorFitments(int tenantID, int IMPageSize, int IMpageNumber, bool IsCount = false, int partID = 0, string yearsearch = "", string makesearch = "", string modelsearch = "")
        {
            IEnumerable<MDLGetErrorFitments> getErrorFitmentsMain;
            int totalRecordCount = 0;
            CustomQueryBuillder.AddUniversalCollectionColumns(tenantID);
            string where = string.Empty;

            if (!string.IsNullOrEmpty(yearsearch))
            {
                where = "AND YEAR LIKE '%" + yearsearch + "%'";
            }
            if (!string.IsNullOrEmpty(makesearch))
            {
                where += "AND Make LIKE '%" + makesearch + "%'";
            }
            if (!string.IsNullOrEmpty(modelsearch))
            {
                where += "AND Model LIKE '%" + modelsearch + "%'";
            }

            getErrorFitmentsMain = PartsHelper.GetErrorFitments(tenantID, partID, IMpageNumber, IMPageSize, where, "");

            if (!IsCount)
            {
                return getErrorFitmentsMain;
            }
            else
            {
                foreach (var item in getErrorFitmentsMain)
                {
                    totalRecordCount = item.Total;
                    if (totalRecordCount > 0)
                    {
                        break;
                    }
                }
                return totalRecordCount;
            }
        }

        //----------------*SUB Used Methods*---------------------//

        public static int MGetAllCount(int tenantID, string partID)
        {
            string tablename = "tools.FitmentsSaved_" + tenantID;
            string flagTablename = "FitmentsSaved_" + tenantID;
            string Query = "";
            string temptablename = "tools.FitmentsTemp_" + tenantID;
            string flagTempTablename = "FitmentsTemp_" + tenantID;
            int[] fitmentcount = new int[3];

            Query = CustomQueryBuillder.GetTempFitmentsCountQuery(temptablename, flagTempTablename, tenantID, Convert.ToInt32(partID));

            fitmentcount[0] = CustomQueryBuillder.Getcount(Query, tenantID, Convert.ToInt32(partID));
            Query = CustomQueryBuillder.GetSavedFitmentsCountQuery(tablename, flagTablename, 1, tenantID, Convert.ToInt32(partID));

            fitmentcount[1] = CustomQueryBuillder.Getcount(Query);
            Query = CustomQueryBuillder.GetSavedFitmentsCountQuery(tablename, flagTablename, 0, tenantID, Convert.ToInt32(partID));

            fitmentcount[2] = CustomQueryBuillder.Getcount(Query);
            return fitmentcount[1];
        }

        public static int MGetSavedFitmentsCount(int tenantID, string partID)
        {
            IEnumerable<MDLGetSavedFitments> getSavedFitmentsInfoMain;
            int totalRecordCount = 0;
            CustomQueryBuillder.AddUniversalCollectionColumns(tenantID);
            getSavedFitmentsInfoMain = PartsHelper.GetSavedFitment(tenantID, Convert.ToInt32(partID), 0, 0, "", "");

            foreach (var item in getSavedFitmentsInfoMain)
            {
                totalRecordCount = item.Total;
                if (totalRecordCount > 0)
                {
                    break;
                }
            }
            return totalRecordCount;
        }

        public static int MGetErrorFitmentsCount(int tenantID, string partID)
        {
            IEnumerable<MDLGetErrorFitments> getErrorFitmentsMain;
            int totalRecordCount = 0;
            CustomQueryBuillder.AddUniversalCollectionColumns(tenantID);
            getErrorFitmentsMain = PartsHelper.GetErrorFitments(tenantID, Convert.ToInt32(partID), 0, 0, "", "");

            foreach (var item in getErrorFitmentsMain)
            {
                totalRecordCount = item.Total;
                if (totalRecordCount > 0)
                {
                    break;
                }
            }
            return totalRecordCount;
        }

    }
}
