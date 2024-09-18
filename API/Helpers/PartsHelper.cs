using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using PartsConnectWebTools.Models.Custom;
using System.Text;
using System.Text.RegularExpressions;
using TestRestAPI.Models.Utilities;
using PCFitment_API.Models;
using PCFitment_API.IService;
using Dapper;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;

namespace PartsConnectWebTools.Helpers
{
    static class PartsHelper
    {
        static string myConnectionString = clsConnection.CommonConnString();
        static StringBuilder stbSqlQuery = new StringBuilder();

        #region UnusedMethod

        public static IEnumerable<MDLGetSavedFitments> GetSavedFitment(int tenantID, int partID, int Start, int size, string where, string order)
        {
            string tablename = "tools.FitmentsSaved_" + tenantID;
            string flagTablename = "FitmentsSaved_" + tenantID;
            IEnumerable<MDLGetSavedFitments> fits;
            string Query = CustomQueryBuillder.read_unique_data_from_fitmentssaved(partID, tenantID, flagTablename, tablename, Start, size, where, order);
            using (var conn = new SqlConnection(clsConnection.CommonConnString()))
            {
                conn.Open();
                fits = conn.Query<MDLGetSavedFitments>(Query, new { TenantID = tenantID, PartID = partID }, null, true, 100000).ToList();
                conn.Close();
            }
            return fits;
        }

        public static IEnumerable<MDLGetErrorFitments> GetErrorFitments(int tenantID, int partID, int Start, int size, string where, string order)
        {
            string tablename = "tools.FitmentsSaved_" + tenantID;
            string flagTablename = "FitmentsSaved_" + tenantID;
            IEnumerable<MDLGetErrorFitments> fits;
            //
            if (string.IsNullOrWhiteSpace(order))
            {
                order = " ORDER BY ID ";
            }
            string Query = @"DECLARE @flag1 INT  SELECT @flag1 = COUNT(*)FROM INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + flagTablename + @"' AND TABLE_SCHEMA = 'tools';             IF ISNULL(@flag1,0)<> 0     BEGIN
SELECT COUNT(*) over () AS Total,  MAX(ID) AS ID,  TenantID,PartID,Make,Year,Model,VehicleType,Region,SubModel,Liter,CC,CID, 
                Cylinders,BlockType,EngBoreIn,EngBoreMetric,
                EngStrokeIn,EngStrokeMetric,EngineDesignationName,EngineVersion,EngineVIN,Aspiration,CylinderHeadTypeName,FuelTypeName,
                FuelSystemDesignName,FuelDeliveryTypeName,FuelDeliverySubTypeName,BodyNumDoors,BodyType,BrakeABSName,MfrBodyCodeName,
                FrontBrakeType,DriveTypeName,SteeringSystemName,TransmissionMfrCode,TransmissionControlTypeName,TransmissionNumSpeeds,
                TransmissionTypeName,PartType ,Qty,Position,Note,Action,UserID, isActive,isAdmin,Mapped,Resion,BrakeSystemName,
                RearBrakeType,BaseVehicleID,SubModelID,RegionID,EngineBaseID,Validate,VehicleTypeID,EngineDesignationID,EngineVersionID,
                EngineVINID,AspirationID,CylinderHeadTypeID,FuelTypeID,FuelSystemDesignID,FuelDeliveryTypeID,FuelDeliverySubTypeID,
                BodyNumDoorsID,BodyTypeID,BrakeABSID,MfrBodyCodeID,FrontBrakeID,DriveTypeID,SteeringSystemID,TransmissionMfrCodeID,
                TransmissionControlTypeID,TransmissionNumSpeedsID,TransmissionTypeID, PartTypeID,PositionID,PowerOutputID, 
                HorsePower, KilowattPower,ValvesPerEngineID,ValvesPerEngine,IgnitionSystemTypeID,IgnitionSystemTypeName,BedTypeID,BedTypeName,
                WheelBaseID,WheelBase,WheelBaseMetric,FrontSpringTypeID,FrontSpringTypeName,RearSpringTypeID,RearSpringTypeName,SteeringTypeID,
                SteeringTypeName,DisplayOrder,AssetName,AssetItemOrder,AssetItemRef,EngineMfrID,EngineMfrName,TransmissionMfrID,
                TransmissionMfrName,FuelSystemControlTypeID,FuelSystemControlTypeName,TransElecControlledID,TransElecControlledName,
                BedLengthID,BedLength,BrakeSystemID,RearBrakeID,TransmissionBaseID FROM " + tablename + @" WHERE TenantID=@TenantID AND PartID=@PartID AND ISNULL(Action,'')='A' AND ISNULL(IsInvalid,0)=1 AND ISNULL(IsDeleted,0)<>1  " + where + @" GROUP BY TenantID,PartID,Make,Year,Model,VehicleType,Region,SubModel,Liter,CC,CID, 
                Cylinders,BlockType,EngBoreIn,EngBoreMetric,
                EngStrokeIn,EngStrokeMetric,EngineDesignationName,EngineVersion,EngineVIN,Aspiration,CylinderHeadTypeName,FuelTypeName,
                FuelSystemDesignName,FuelDeliveryTypeName,FuelDeliverySubTypeName,BodyNumDoors,BodyType,BrakeABSName,MfrBodyCodeName,
                FrontBrakeType,DriveTypeName,SteeringSystemName,TransmissionMfrCode,TransmissionControlTypeName,TransmissionNumSpeeds,
                TransmissionTypeName,PartType ,Qty,Position,Note,Action,UserID, isActive,isAdmin,Mapped,Resion,BrakeSystemName,
                RearBrakeType,BaseVehicleID,SubModelID,RegionID,EngineBaseID,Validate,VehicleTypeID,EngineDesignationID,EngineVersionID,
                EngineVINID,AspirationID,CylinderHeadTypeID,FuelTypeID,FuelSystemDesignID,FuelDeliveryTypeID,FuelDeliverySubTypeID,
                BodyNumDoorsID,BodyTypeID,BrakeABSID,MfrBodyCodeID,FrontBrakeID,DriveTypeID,SteeringSystemID,TransmissionMfrCodeID,
                TransmissionControlTypeID,TransmissionNumSpeedsID,TransmissionTypeID, PartTypeID,PositionID,PowerOutputID, 
                HorsePower, KilowattPower,ValvesPerEngineID,ValvesPerEngine,IgnitionSystemTypeID,IgnitionSystemTypeName,BedTypeID,BedTypeName,
                WheelBaseID,WheelBase,WheelBaseMetric,FrontSpringTypeID,FrontSpringTypeName,RearSpringTypeID,RearSpringTypeName,SteeringTypeID,
                SteeringTypeName,DisplayOrder,AssetName,AssetItemOrder,AssetItemRef,EngineMfrID,EngineMfrName,TransmissionMfrID,
                TransmissionMfrName,FuelSystemControlTypeID,FuelSystemControlTypeName,TransElecControlledID,TransElecControlledName,
                BedLengthID,BedLength,BrakeSystemID,RearBrakeID,TransmissionBaseID " + order;

            if (size > 0)
            {
                Query += @"  OFFSET ((" + size + ")*((" + Start + ") - 1)) ROWS FETCH NEXT(" + size + ") ROWS ONLY END";
            }
            else
            {
                Query += " END";
            }

            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                fits = conn.Query<MDLGetErrorFitments>(Query, new { TenantID = tenantID, PartID = partID }, null, true, 100000).ToList();
                conn.Close();
            }
            return fits;
        }

        public static void AddUniversalCollectionColumns(int tenantID)
        {
            string Query = @"
            IF EXISTS (SELECT * FROM   INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = 'Parts_" + tenantID + @"'AND TABLE_SCHEMA = 'tools')
            BEGIN
                IF NOT EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE
                                    TABLE_NAME = 'Parts_" + tenantID + @"' AND COLUMN_NAME = 'collectionId' AND TABLE_SCHEMA = 'tools')
                BEGIN
                        ALTER TABLE tools.Parts_" + tenantID + @" ADD collectionId INT NOT NULL DEFAULT 0;
                END

                IF NOT EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE
                                    TABLE_NAME = 'Parts_" + tenantID + @"' AND COLUMN_NAME = 'PrevcollectionId' AND TABLE_SCHEMA = 'tools')
                BEGIN
                        ALTER TABLE tools.Parts_" + tenantID + @" ADD PrevcollectionId INT NULL;
                END

                IF NOT EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE
                                    TABLE_NAME = 'Parts_" + tenantID + @"' AND COLUMN_NAME = 'InitialSubmission' AND TABLE_SCHEMA = 'tools')
                BEGIN
                        ALTER TABLE tools.Parts_" + tenantID + @" ADD InitialSubmission BIT NOT NULL DEFAULT 0;
                END

                IF NOT EXISTS ( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE
                    TABLE_NAME = 'Parts_" + tenantID + @"' AND COLUMN_NAME = 'LastSubmissionDate' AND TABLE_SCHEMA = 'tools')
                BEGIN
                    ALTER TABLE tools.Parts_" + tenantID + @" ADD LastSubmissionDate DATETIME NULL;
                END
            END; ";
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                conn.Query(Query);
                conn.Close();
            }

        }

        public static IEnumerable<PartDisplay> GetAllSKU(int tenantID)
        {
            IEnumerable<PartDisplay> parts;
            List<PartDisplay> results = new List<PartDisplay>();
            try
            {
                string q = $@"SELECT  mapping.SKU ,Count(mapping.SKU) TotalFitments FROM tools.FitmentsSaved_{tenantID} x
            Inner Join tools.Parts_{tenantID} part ON X.partid = part.id
            Inner Join tools.ParteBaySKU_{tenantID} mapping ON mapping.PartNumber = part.PartNumber
            AND part.tenantid = {tenantID} and isnull(mapping.SKU,'') != '' AND ISNULL(mapping.IsDeleted,0) = 0
            WHERE ISNULL(X.isinvalid, 0) = 0
            and ISNULL(part.isdeleted,0) = 0
            and (ISNULL(isEbaySubmited, 0) = 0 and ISNULL(isfinalSubmitEbay,0) = 0) GROUP BY SKU";
                using (var conn = new SqlConnection(myConnectionString))
                {
                    conn.Open();
                    results = conn.Query<PartDisplay>(q, new { TenantID = tenantID }, null, true, 100000).ToList();
                    conn.Close();
                }


            }
            catch (Exception ex)
            {


            }

            parts = results.Select(x => new PartDisplay
            {
                PartTerminologyID = x.PartTerminologyID,
                PartTypeName = x.PartTypeName,
                SKU = x.SKU,
                Isinvalid = x.Isinvalid,
                TotalFitments = x.TotalFitments
            }
               );
            return parts;
        }

        public static int GetTotalSKUs(int tenantID)
        {
            int totalsku = 0;
            string Query = @" SELECT COUNT(SKU) AS TotalCount FROM tools.ParteBaySKU_" + tenantID + @" WHERE ISNULL(IsDeleted,0) = 0";
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                try
                {
                    totalsku = Convert.ToInt32(conn.Query<string>(Query).FirstOrDefault());
                }
                catch (Exception ex)
                {

                }

                conn.Close();
            }
            return totalsku;
        }

        public static int GeteBayFitmentcount(int tenantID)
        {
            int fitmentCount = 0;
            DataTable gbldtTemp = new DataTable();
            try
            {
                if (commonMethods.IsEbayUser())
                {
                    string PartTable = "tools.Parts_" + tenantID;
                    string PartEbayMapping = "tools.ParteBaySKU_" + tenantID;
                    string FitmentsSaved = "tools.FitmentsSaved_" + tenantID;
                    //string s = @"SELECT  SKU,Count(SKU) as TotalFitment FROM  " + FitmentsSaved + " x " +
                    // " Inner Join " + PartTable + " part ON X.partid = part.id " + " AND part.tenantid = " + tenantID + " " +
                    // " Inner Join " + PartEbayMapping + " mapping ON mapping.partNumber = part.PartNumber " + " AND ISNULL(mapping.SKU,'') != ''  " +
                    // " WHERE ISNULL(X.iseBayInvalid, 0) = 0 AND (ISNULL(X.isfinalSubmitEbay, 0) = 0 OR ISNULL(X.isEbaySubmited, 0) = 0) AND ISNULL(x.Action,'')='A'  AND ISNULL(X.isinvalid, 0) = 0 " +
                    // " GROUP BY SKU";
                    string s = @" SELECT SKU,Count(SKU) as TotalFitment FROM  " + FitmentsSaved + " x " +
              " Inner Join " + PartTable + " part ON X.partid = part.id " + " AND part.tenantid = " + tenantID + " " +
              " Inner Join " + PartEbayMapping + " mapping ON  mapping.partNumber = part.PartNumber  AND ISNULL(mapping.SKU,'') != '' AND ISNULL(mapping.IsDeleted,0) = 0  " +
                "AND(ISNULL(X.isfinalSubmitEbay, 0) = 0 OR ISNULL(mapping.isInitialSubmitted, 0) = 0) AND ISNULL(X.iseBayInvalid, 0) = 0" +
              " GROUP BY SKU";
                    using (var conn = new SqlConnection(myConnectionString))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(s, conn);
                        da.Fill(gbldtTemp);
                    }
                }

                if (gbldtTemp.Rows.Count > 0)
                {
                    fitmentCount = Convert.ToInt32(gbldtTemp.Rows[0]["TotalFitment"].ToString());
                }
            }
            catch (Exception ex)
            {
            }
            return fitmentCount;
        }

        #endregion


        public static bool checkParentColumn(Int64 tenantID = 0)
        {
            string tablename = "Parts_" + tenantID;
            bool IsExist = false;
            string columnName = "ParentPartID";
            string Query = $@"SELECT COUNT(*) AS Ccount FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '" + tablename + "' AND COLUMN_NAME = '" + columnName + "' ";
            int intcount = 0;
            using (var conn = new SqlConnection(clsConnection.CommonConnString()))
            {
                conn.Open();
                intcount = conn.Query<int>(Query, null, null, true, 100000).FirstOrDefault();
                conn.Close();
            }
            if (intcount > 0)
            {
                IsExist = true;
            }
            return IsExist;
        }

        public static void AddParantIdcolnm(Int64 tenantID = 0)
        {
            string[] columnNames = { "ParentPartID", "IsInheritPartInitSub", "LastInheritPartSubDate" };
            string dynamicQuery = @"";
            dynamicQuery = @"IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Parts_" + tenantID + @"' AND TABLE_SCHEMA = 'tools')
                                BEGIN";
            foreach (string columnName in columnNames)
            {

                if (columnName.ToLower() == "parentpartid" || columnName.ToLower() == "prevparentid")
                {
                    dynamicQuery += @" IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE
                                        TABLE_NAME = 'Parts_" + tenantID + @"' AND COLUMN_NAME = '" + columnName.Trim() + @"' AND TABLE_SCHEMA = 'tools')
                    BEGIN
                         ALTER TABLE tools.Parts_" + tenantID + @" ADD [" + columnName.Trim() + @"] INT ; END";
                }
                else if (columnName.ToLower() == "isinheritpartinitsub" || columnName == "issubmittedasinherited")
                {
                    dynamicQuery += @" IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE
                                        TABLE_NAME = 'Parts_" + tenantID + @"' AND COLUMN_NAME = '" + columnName.Trim() + @"' AND TABLE_SCHEMA = 'tools')
                    BEGIN
                         ALTER TABLE tools.Parts_" + tenantID + @" ADD[" + columnName.Trim() + @"] BIT NOT NULL DEFAULT 0 ; END";
                }
                else if (columnName.ToLower() == "lastinheritpartsubdate")
                {
                    dynamicQuery += @" IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE
                                        TABLE_NAME = 'Parts_" + tenantID + @"' AND COLUMN_NAME = '" + columnName.Trim() + @"' AND TABLE_SCHEMA = 'tools')
                    BEGIN
                         ALTER TABLE tools.Parts_" + tenantID + @" ADD[" + columnName.Trim() + @"] DATETIME ; END";
                }
            }

            dynamicQuery += @" END;";

            // Execute the dynamic query
            using (var conn = new SqlConnection(clsConnection.CommonConnString()))
            {
                conn.Open();
                conn.Query(dynamicQuery);
                conn.Close();
            }
        }

        public static MDLInheritedParts GetInheritPartDetailById(Int64 partID = 0, Int64 TenantID = 0)
        {
            string Query = @"";
            MDLInheritedParts inheritedParts = new MDLInheritedParts();

            string tablename = "tools.Parts_" + TenantID;
            Query = @"SELECT p.Id, p.TenantID, p.PartNumber, p.ASIN, p.ManufactureLabel, p.PartDescription, p.BrandID, 
                             p1.PartNumber AS ParentPartNumber, p2.PartTerminologyName AS PartType, p1.id AS ParentPartID
                             FROM " + tablename + @" p
                             INNER JOIN " + tablename + @" p1 ON p1.id = p.ParentPartID
                             INNER JOIN Parts p2 ON p2.PartTerminologyID = p.PartTerminologyID
                             WHERE p.ID = @PartId AND ISNULL(P.IsDeleted,0)=0 AND ISNULL(p1.IsDeleted,0)=0";
            

            using (var conn = new SqlConnection(clsConnection.CommonConnString()))
            {
                conn.Open();
                inheritedParts = conn.Query<MDLInheritedParts>(Query, new { TenantID = TenantID, partID = partID }, null, true, 100000).FirstOrDefault();
                conn.Close();
            }
            return inheritedParts;

        }

        public static string GetFitmetnCount(Int64 partID = 0, Int64 TenantID = 0)
        {
            string tablename1 = "tools.FitmentsSaved_" + TenantID;
            string TableNmae2 = "tools.Parts_" + TenantID;
            string FitmentsCount = "0";
            string Query = "";
            Query = @"SELECT COUNT(DISTINCT A.id) FROM " + tablename1 + @" A INNER JOIN " + TableNmae2 + @" B ON A.PartID=B.ParentPartID WHERE ISNULL(B.IsDeleted,0)=0
                      AND ISNULL(A.IsDeleted,0)=0 AND ISNULL(A.IsInvalid,0) = 0 AND B.ID = " + partID + " ";
            using (var conn = new SqlConnection(clsConnection.CommonConnString()))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(Query, conn);
                string getValue = cmd.ExecuteScalar().ToString();
                if (getValue != null)
                {
                    FitmentsCount = Convert.ToString(getValue.ToString());
                }
                conn.Close();
            }
            return FitmentsCount;
        }

        public static string GetPartNumber(string tenantID, string partNumber)
        {
            string PartNumber = "";
            string tablename = "tools.Parts_" + tenantID;
            string Query = @"SELECT PartNumber FROM " + tablename + " WHERE PartNumber=@PartNumber AND TenantID=@TenantID AND ISNULL(IsDeleted,0)<>1 ";
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(clsConnection.CommonConnString()))
            {
                SqlDataAdapter da = new SqlDataAdapter(Query, conn);
                da.SelectCommand.Parameters.AddWithValue("@PartNumber", partNumber.Trim());
                da.SelectCommand.Parameters.AddWithValue("@TenantID", tenantID);
                da.Fill(dt);
            }
            if (dt.Rows.Count > 0)
            {
                PartNumber = dt.Rows[0]["PartNumber"].ToString();
            }
            return PartNumber;
        }

        public static DataTable GetPartNumberDetails(string tenantId, string PartId)
        {
            string Query = @"SELECT * FROM tools.Parts_" + tenantId + @" where ISNULL(IsDeleted,0)=0 AND ID=" + PartId + @"";
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(clsConnection.CommonConnString()))
            {
                SqlDataAdapter da = new SqlDataAdapter(Query, conn);
                da.Fill(dt);
            }
            return dt;
        }
        public static int AddChildPart(string tenantId, string NewPartNumber, string ASIN, string ManufactureLabel, string PartDescription, string PartTerminologyID, string BrandID, string ParentPartID)
        {
            string Query = @"INSERT INTO tools.Parts_" + tenantId + @"(TenantID,PartNumber,[ASIN],ManufactureLabel,PartDescription,PartTerminologyID, BrandID,ParentPartID) 
                             VALUES (" + tenantId + @",'" + NewPartNumber + @"','" + ASIN + @"','" + ManufactureLabel + @"','" + PartDescription + @"'," + PartTerminologyID +
                             @",'" + BrandID + @"'," + ParentPartID + @") SELECT SCOPE_IDENTITY()";
            int id = 0;
            using (var conn = new SqlConnection(clsConnection.CommonConnString()))
            {
                conn.Open();
                id = Convert.ToInt32(conn.Query<string>(Query).FirstOrDefault());
                conn.Close();
            }

            return id;
        }

        public static bool CheckPartsTable(string tenantID)
        {
            string tablename = "Parts_" + tenantID;
            string Query = @"SELECT * FROM INFORMATION_SCHEMA.TABLES
                WHERE TABLE_SCHEMA = N'tools'  AND TABLE_NAME = N'" + tablename + "'";
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(clsConnection.CommonConnString()))
            {
                SqlDataAdapter da = new SqlDataAdapter(Query, conn);
                da.Fill(dt);
            }
            if (dt.Rows.Count > 0)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public static IEnumerable<MDLInheritedParts> GetAllInheritedParts(Int64 TenantId = 0, Int64 PartId = 0)
        {
            IEnumerable<MDLInheritedParts> inheritedParts;
            string tablename = "tools.Parts_" + TenantId;

            string Query = "";
            Query = CustomQueryBuillder.BuildQueryForInheritedParts(PartId, TenantId);
            using (var conn = new SqlConnection(clsConnection.CommonConnString()))
            {
                conn.Open();
                inheritedParts = conn.Query<MDLInheritedParts>(Query, new { TenantID = TenantId }, null, true, 100000).ToList();
                conn.Close();
            }

            return inheritedParts;
        }
    }
}