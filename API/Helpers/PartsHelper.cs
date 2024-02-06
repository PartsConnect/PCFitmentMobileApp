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

    }
}