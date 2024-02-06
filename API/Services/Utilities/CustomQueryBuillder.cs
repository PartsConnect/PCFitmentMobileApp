using Microsoft.Extensions.Primitives;
using PartsConnectWebTools.Helpers;
using PartsConnectWebTools.Models.Custom;
using PCFitment_API.Models;
using System.Data.SqlClient;
using System.Runtime.CompilerServices;
using System.Security.Claims;
using System.Text;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

namespace TestRestAPI.Models.Utilities
{
    public class CustomQueryBuillder
    {
        protected static StringBuilder stbSqlQuery = new StringBuilder();
        protected static string connString = clsConnection.CommonConnString();
        public static string GetPartsQuery(int tenantID)
        {
            string SelectItem = "P.ID";
            string Query = CommonPartsCount(tenantID, SelectItem);
            return Query;
        }
        public static string GetFitmentsSavedCountQuery(int tenantID)
        {
            string tablename = "tools.FitmentsSaved_" + tenantID;
            string flagtable = "FitmentsSaved_" + tenantID;
            string Query = @" DECLARE @SQLCommand varchar(max)
            IF NOT EXISTS (SELECT * FROM   INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + flagtable + @"'AND TABLE_SCHEMA = 'tools')
            BEGIN
                 SELECT @SQLCommand =''
            END
            ELSE
            BEGIN
                 SELECT @SQLCommand ='SELECT COUNT(ID) FROM  " + tablename + @" WHERE TenantID=" + tenantID + @" AND ISNULL(BaseVehicleID, 0) <> 0 AND ISNULL(IsDeleted, 0) <> 1'
            END
             EXEC (@SQLCommand)";
            return Query;
        }
        public static string GetTotalPartQuery(int tenantID)
        {
            string SelectItem = "DISTINCT F.PartTerminologyName";
            string Query = CommonPartsCount(tenantID, SelectItem);
            return Query;
        }
        public static string CommonPartsCount(int tenantID, string SelectItem)
        {
            string tablename = "tools.Parts_" + tenantID;
            string flagtable = "Parts_" + tenantID;
            string Query = @"IF EXISTS (SELECT * FROM   INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + flagtable + @"'AND TABLE_SCHEMA = 'tools')
            BEGIN
                SELECT COUNT( " + SelectItem + @") AS PartCount FROM  " + tablename + @"  
                 P JOIN Parts F ON P.PartTerminologyID=F.PartTerminologyID
                WHERE P.TenantID=" + tenantID + @" AND ISNULL(P.IsDeleted, 0) = 0
            END
            ELSE
            BEGIN
                 SELECT 0 AS PartCount
            END";
            return Query;
        }
        public static string GetNewPartTypeQuery(int tenantID)
        {
            string SelectItem = "DISTINCT F.PartTerminologyName";
            string Query = CommonQuery(tenantID, SelectItem);
            return Query;
        }
        public static string CommonQuery(int tenantID, string SelectItem)
        {
            string tablename1 = "tools.Parts_" + tenantID;
            string tablename2 = "tools.FitmentsSaved_" + tenantID;
            string flagtable2 = "FitmentsSaved_" + tenantID;
            string flagtable1 = "Parts_" + tenantID;
            string Query = "";
            Query = @" DECLARE @flag1 INT
                       DECLARE @flag2 INT
                       SELECT @flag1 = COUNT(*)FROM INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + flagtable1 + @"' AND TABLE_SCHEMA = 'tools';
                        SELECT @flag2 = COUNT(*)FROM INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + flagtable2 + @"' AND TABLE_SCHEMA = 'tools';
                 
                     IF ISNULL(@flag1,0)=1
                     BEGIN
                       IF ISNULL(@flag2, 0) =1
                       BEGIN
                         SELECT COUNT(" + SelectItem + @") AS PartCount FROM  " + tablename1 + @" AS p INNER JOIN Parts F ON P.PartTerminologyID=F.PartTerminologyID 
		                LEFT JOIN (SELECT DISTINCT PartID FROM  " + tablename2 + @" WHERE ISNULL(isAmazonSubmited,0) = 1 AND TenantID=" + tenantID + @" ) temp ON temp.PartID = p.ID WHERE p.TenantID=" + tenantID + @" AND ISNULL(p.IsDeleted, 0) =0  AND temp.PartID IS NULL
                       END
                       ELSE
                       BEGIN
                          SELECT COUNT(" + SelectItem + @") AS PartCount FROM " + tablename1 + @" AS p JOIN Parts F ON P.PartTerminologyID=F.PartTerminologyID WHERE p.TenantID=" + tenantID + @"
                       END
                END
            ELSE
             BEGIN
                 SELECT 0 AS PartCount;
             END ";
            return Query;
        }
        public static string GetNewPartsQuery(int tenantID)
        {
            string SelectItem = "P.ID";
            string Query = CommonQuery(tenantID, SelectItem);
            return Query;
        }
        public static string GetNewFitmentsQuery(int tenantID)
        {
            string tablename = "tools.FitmentsSaved_" + tenantID;
            string flagtable = "FitmentsSaved_" + tenantID;
            string Query = @" DECLARE @SQLCommand varchar(max)
            IF NOT EXISTS (SELECT * FROM   INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + flagtable + @"'AND TABLE_SCHEMA = 'tools')
            BEGIN
                 SELECT @SQLCommand =''
            END
            ELSE
            BEGIN
                 SELECT @SQLCommand ='SELECT COUNT(ID) FROM  " + tablename + @" WHERE TenantID=" + tenantID + @" AND ISNULL(isAmazonSubmited,0) = 0 AND ISNULL(BaseVehicleID, 0) <> 0 AND ISNULL(IsDeleted, 0) = 0 '
            END
             EXEC (@SQLCommand)";
            return Query;
        }
        public static string GetTotalUniversalPartsQuery(int tenantID)
        {
            AddUniversalCollectionColumns(tenantID);
            string tablename = "tools.Collection";
            string flagtable = "Collection";
            string Query = @" DECLARE @SQLCommand varchar(max)
            IF NOT EXISTS (SELECT * FROM   INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + flagtable + @"' AND TABLE_SCHEMA = 'tools')
            OR NOT EXISTS (SELECT * FROM   INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = 'Parts_" + tenantID + @"' AND TABLE_SCHEMA = 'tools')
            BEGIN
                 SELECT @SQLCommand =''
            END
            ELSE
            BEGIN
                 SELECT @SQLCommand =' SELECT COUNT(P.PartNumber) FROM " + tablename + @" AS C INNER JOIN tools.Parts_" + tenantID + @" AS P ON P.CollectionID = C.ID 
							WHERE ISNULL(P.IsDeleted,0) = 0  AND ISNULL(C.IsDeleted,0) = 0 AND C.TenantID = " + tenantID + @" '
            END
             EXEC (@SQLCommand)";
            return Query;
        }
        public static string GetTotalCollectionQuery(int tenantID)
        {
            string tablename = "tools.Collection";
            string flagtable = "Collection";
            string Query = @" DECLARE @SQLCommand varchar(max)
            IF NOT EXISTS (SELECT * FROM   INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + flagtable + @"' AND TABLE_SCHEMA = 'tools')
            BEGIN
                 SELECT @SQLCommand =''
            END
            ELSE
            BEGIN
                 SELECT @SQLCommand =' SELECT COUNT(*) FROM " + tablename + @" WHERE ISNULL(IsDeleted,0) = 0 AND TenantID = " + tenantID + @" '
            END
             EXEC (@SQLCommand)";
            return Query;
        }
        public static string GetTotalCollectionWithoutPartsQuery(int tenantID)
        {
            AddUniversalCollectionColumns(tenantID);
            string tablename = "tools.Collection";
            string flagtable = "Collection";
            string Query = @" DECLARE @SQLCommand varchar(max)
            IF NOT EXISTS (SELECT * FROM   INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + flagtable + @"' AND TABLE_SCHEMA = 'tools')
            OR NOT EXISTS (SELECT * FROM   INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = 'Parts_" + tenantID + @"' AND TABLE_SCHEMA = 'tools')
            BEGIN
                 SELECT @SQLCommand =''
            END
            ELSE
            BEGIN
                 SELECT @SQLCommand =' SELECT COUNT(*) FROM " + tablename + @" AS C LEFT JOIN tools.Parts_" + tenantID + @" AS P ON P.CollectionID = C.ID 
							WHERE P.PartNumber IS NULL AND ISNULL(C.IsDeleted,0) = 0 AND C.TenantID = " + tenantID + @" '
            END
             EXEC (@SQLCommand)";
            return Query;
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
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(Query);

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    command.ExecuteNonQuery();
                }
                connection.Close();
            }
        }
        public static string BuildQueryForParts(int item, int TenantID, string PartTableName, string fitmentTableName, int Start, int size, string LikeOptions, bool IsCount)
        {
            string Flag1tablename = "Parts_" + TenantID;
            string Flag2tablename = "FitmentsSaved_" + TenantID;
            stbSqlQuery.Clear();

            if (item == 2)
            {
                if (commonMethods.IsBrandShowMenu(TenantID))
                {
                    stbSqlQuery.Append(@" SELECT DISTINCT  COUNT(*) over () AS Total, p.PartTerminologyName AS PartTypeName ,ISNULL(F.isinvalid,0) AS  Isinvalid ,p1.ID,p1.PartTerminologyID,
                             p1.ASIN,p1.ManufactureLabel,p1.PartTerminologyID,p1.BrandID,p1.PartDescription,p1.TenantID,p1.PartNumber,p1.collectionId,p1.IsAmazonFit FROM " + PartTableName + @" p1 
                             JOIN Parts p ON p1.PartTerminologyID = p.PartTerminologyID  
                        INNER JOIN (SELECT DISTINCT PartID,isinvalid,IsDeleted FROM  " + fitmentTableName + @" WHERE ISNULL(isinvalid,0) =1 AND ISNULL(Action,'''') =''A'')
                           F ON F.PartID=p1.ID 
                             WHERE p1.TenantID =" + TenantID + @"  AND ISNULL(F.isinvalid,0)=1 AND ISNULL(p1.IsDeleted,0)=0 AND ISNULL(F.IsDeleted,0)=0 ");

                    stbSqlQuery.Append("  AND ( (PartNumber LIKE ''%" + LikeOptions + "%'') ");
                    stbSqlQuery.Append("  OR (PartTerminologyName LIKE ''%" + LikeOptions + "%'') ");
                    stbSqlQuery.Append("  OR (BrandID LIKE ''%" + LikeOptions + "%'') ");
                    stbSqlQuery.Append("  OR (p1.PartTerminologyID LIKE ''%" + LikeOptions + "%'') ");
                    stbSqlQuery.Append(" ) ORDER BY ID ");

                    if (!IsCount)
                    {
                        stbSqlQuery.Append(@" OFFSET ((" + size + ")*((" + Start + ") - 1)) ROWS FETCH NEXT(" + size + ") ROWS ONLY ; ");
                    }
                }
                else
                {
                    stbSqlQuery.Append(@" SELECT DISTINCT  COUNT(*) over () AS Total, p.PartTerminologyName AS PartTypeName ,ISNULL(F.isinvalid,0) AS  Isinvalid ,p1.ID,p1.PartTerminologyID,
                             p1.ASIN,p1.ManufactureLabel, p1.PartTerminologyID, p1.BrandID, p1.PartDescription,p1.TenantID,p1.PartNumber,p1.collectionId,p1.IsAmazonFit FROM " + PartTableName + @" p1 
                             JOIN Parts p ON p1.PartTerminologyID = p.PartTerminologyID  
                        INNER JOIN (SELECT DISTINCT PartID,isinvalid,IsDeleted FROM  " + fitmentTableName + @" WHERE ISNULL(isinvalid,0) =1 AND ISNULL(Action,'''') =''A'')
                           F ON F.PartID=p1.ID 
                             WHERE p1.TenantID =" + TenantID + @"  AND ISNULL(F.isinvalid,0)=1 AND ISNULL(p1.IsDeleted,0)=0 AND ISNULL(F.IsDeleted,0)=0 ");

                    stbSqlQuery.Append("  AND ( (PartNumber LIKE ''%" + LikeOptions + "%'') ");
                    stbSqlQuery.Append("  OR (PartTerminologyName LIKE ''%" + LikeOptions + "%'') ");
                    stbSqlQuery.Append("  OR (BrandID LIKE ''%" + LikeOptions + "%'') ");
                    stbSqlQuery.Append("  OR (p1.PartTerminologyID LIKE ''%" + LikeOptions + "%'') ");
                    stbSqlQuery.Append(" ) ORDER BY ID ");

                    if (!IsCount)
                    {
                        stbSqlQuery.Append(@" OFFSET ((" + size + ")*((" + Start + ") - 1)) ROWS FETCH NEXT(" + size + ") ROWS ONLY ; ");
                    }

                }
            }
            else
            {
                if (commonMethods.IsBrandShowMenu(TenantID))
                {
                    stbSqlQuery.Append(@" SELECT DISTINCT  COUNT(*) over () AS Total, p.PartTerminologyName AS PartTypeName, CASE WHEN errorFitment.PartID IS NOT NULL THEN 1 ELSE 0 END IsInvalid, p1.ID,p1.PartTerminologyID,
                             p1.ASIN,p1.ManufactureLabel,p1.PartTerminologyID,p1.BrandID,p1.PartDescription,p1.TenantID,p1.PartNumber,p1.collectionId,p1.IsAmazonFit FROM " + PartTableName + @" p1
                JOIN Parts p ON p1.PartTerminologyID = p.PartTerminologyID
                LEFT JOIN  (SELECT DISTINCT PartID FROM  " + fitmentTableName + @"  F WHERE TenantID = " + TenantID + @" AND IsInvalid = 1 AND ISNULL(IsDeleted,0)=0 AND ISNULL(Action,'''')=''A'') AS errorFitment ON errorFitment.PartId = P1.ID
                WHERE p1.TenantID = " + TenantID + @" AND ISNULL(p1.IsDeleted,0)=0 ");

                    stbSqlQuery.Append("  AND ( (PartNumber LIKE ''%" + LikeOptions + "%'') ");
                    stbSqlQuery.Append("  OR (PartTerminologyName LIKE ''%" + LikeOptions + "%'') ");
                    stbSqlQuery.Append("  OR (BrandID LIKE ''%" + LikeOptions + "%'') ");
                    stbSqlQuery.Append("  OR (p1.PartTerminologyID LIKE ''%" + LikeOptions + "%'') ");
                    stbSqlQuery.Append(" ) ORDER BY ID ");

                    if (!IsCount)
                    {
                        stbSqlQuery.Append(@" OFFSET ((" + size + ")*((" + Start + ") - 1)) ROWS FETCH NEXT(" + size + ") ROWS ONLY ; ");
                    }

                }
                else
                {
                    stbSqlQuery.Append(@"SELECT DISTINCT  COUNT(*) over () AS Total, p.PartTerminologyName AS PartTypeName, CASE WHEN errorFitment.PartID IS NOT NULL THEN 1 ELSE 0 END IsInvalid, p1.ID,p1.PartTerminologyID,
                             p1.ASIN,p1.ManufactureLabel,p1.PartTerminologyID,p1.BrandID, p1.PartDescription,p1.TenantID,p1.PartNumber,p1.collectionId,p1.IsAmazonFit FROM " + PartTableName + @" p1
                JOIN Parts p ON p1.PartTerminologyID = p.PartTerminologyID
                LEFT JOIN  (SELECT DISTINCT PartID FROM  " + fitmentTableName + @"  F WHERE TenantID = " + TenantID + @" AND IsInvalid = 1 AND ISNULL(IsDeleted,0)=0 AND ISNULL(Action,'''')=''A'') AS errorFitment ON errorFitment.PartId = P1.ID
                WHERE p1.TenantID = " + TenantID + @" AND ISNULL(p1.IsDeleted,0)=0 ");

                    stbSqlQuery.Append("  AND ( (PartNumber LIKE ''%" + LikeOptions + "%'') ");
                    stbSqlQuery.Append("  OR (PartTerminologyName LIKE ''%" + LikeOptions + "%'') ");
                    stbSqlQuery.Append("  OR (BrandID LIKE ''%" + LikeOptions + "%'') ");
                    stbSqlQuery.Append("  OR (p1.PartTerminologyID LIKE ''%" + LikeOptions + "%'') ");
                    stbSqlQuery.Append(" ) ORDER BY ID ");

                    if (!IsCount)
                    {
                        stbSqlQuery.Append(@" OFFSET ((" + size + ")*((" + Start + ") - 1)) ROWS FETCH NEXT(" + size + ") ROWS ONLY ; ");
                    }
                }
            }
            StringBuilder QueryLCL = new StringBuilder();
            QueryLCL.Append(@" DECLARE @flag1 INT
                       DECLARE @flag2 INT
                       DECLARE @flag3 INT
                        SELECT @flag1 = COUNT(*)FROM INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + Flag1tablename + @"' AND TABLE_SCHEMA = 'tools';
                        SELECT @flag2 = COUNT(*)FROM INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + Flag2tablename + @"' AND TABLE_SCHEMA = 'tools';
                        SELECT @flag3=" + item + @"
                        DECLARE @SQLCommand VARCHAR(MAX)
                     IF ISNULL(@flag1,0)<> 0
                     BEGIN
                        IF ISNULL(@flag2, 0) <> 0
                        BEGIN
                            SET @SQLCommand = '" + stbSqlQuery.ToString() + @"'
                       END
                       ELSE
                       BEGIN
                              IF ISNULL(@flag3, 0) <> 2
                                BEGIN      
                                SET @SQLCommand = 'SELECT DISTINCT  COUNT(*) over () AS Total,p.PartTerminologyName AS PartTypeName, 0 AS IsInvalid, p1.ID,p1.PartTerminologyID,
                             p1.ASIN,p1.ManufactureLabel,p1.PartTerminologyID,p1.PartDescription,p1.TenantID,p1.PartNumber,p1.collectionId,p1.IsAmazonFit FROM " + PartTableName + @" p1 JOIN Parts p ON p1.PartTerminologyID = p.PartTerminologyID
                                  WHERE p1.TenantID = " + TenantID + @" AND ISNULL(p1.IsDeleted, 0)= 0 ");

            stbSqlQuery.Append("  AND ( (PartNumber LIKE ''%" + LikeOptions + "%'') ");
            stbSqlQuery.Append("  OR (PartTerminologyName LIKE ''%" + LikeOptions + "%'') ");
            stbSqlQuery.Append("  OR (BrandID LIKE ''%" + LikeOptions + "%'') ");
            stbSqlQuery.Append("  OR (p1.PartTerminologyID LIKE ''%" + LikeOptions + "%'') ");
            stbSqlQuery.Append(" ) ORDER BY ID ");

            if (!IsCount)
            {
                QueryLCL.Append(@" OFFSET ((" + size + ")*((" + Start + ") - 1)) ROWS FETCH NEXT(" + size + ") ROWS ONLY ; ");
            }
            QueryLCL.Append(@" ' END 
                           ELSE
                                BEGIN      
                                SET @SQLCommand = ''
                                END
                      END
                END
            ELSE
             BEGIN
                 SET @SQLCommand = ''
             END
             EXEC(@SQLCommand);");

            return QueryLCL.ToString();
        }
        public static int Getcount(string query, int tenantID, int partID)
        {
            int Count = 0;
            using (var conn = new SqlConnection(connString))
            {
                conn.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(query);

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), conn))
                {
                    Count = (int)command.ExecuteScalar();
                }
                conn.Close();
            }
            return Count;
        }
        public static int Getcount(string query)
        {
            int Count = 0;
            using (var conn = new SqlConnection(connString))
            {
                conn.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(query);

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), conn))
                {
                    Count = (int)command.ExecuteScalar();
                }
                conn.Close();
            }
            return Count;
        }
        public static string GetTempFitmentsCountQuery(string temptablename, string flagTempTablename, int tenantID, int partID)
        {
            string Query = "";
            Query = @" DECLARE @flag1 INT  SELECT @flag1 = COUNT(*)FROM INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + flagTempTablename + @"' AND TABLE_SCHEMA = 'tools';
           IF ISNULL(@flag1,0)<> 0
               BEGIN
                    SELECT COUNT(ID) FROM " + temptablename + @" WHERE TenantID=" + tenantID + @" AND PartID=" + partID + @"  ;
               END ";

            return Query;
        }
        public static string GetSavedFitmentsCountQuery(string tablename, string flagTablename, int valid, int tenantID, int partID)
        {
            string Query = "", unionQuery = "";
            if (commonMethods.IsCustomFitmentsAccess(tenantID))
            {
                if (valid == 1)
                {
                         unionQuery = @" UNION
                        SELECT DISTINCT TenantID,PartID,Make,Year,Model,VehicleType,Region,SubModel,Liter,CC,CID, 
                        Cylinders,BlockType,EngBoreIn,EngBoreMetric,
                        EngStrokeIn,EngStrokeMetric,EngineDesignationName,EngineVersion,EngineVIN,Aspiration,CylinderHeadTypeName,FuelTypeName,
                        FuelSystemDesignName,FuelDeliveryTypeName,FuelDeliverySubTypeName,BodyNumDoors,BodyType,BrakeABSName,MfrBodyCodeName,
                        FrontBrakeType,DriveTypeName,SteeringSystemName,TransmissionMfrCode,TransmissionControlTypeName,TransmissionNumSpeeds,
                        TransmissionTypeName,PartType ,Qty,'' Position,Note,Action,'' UserID, '' isActive, '' isAdmin, '' Mapped, '' Resion,'' BrakeSystemName,
                        RearBrakeType,0 BaseVehicleID,0 SubModelID, 0 RegionID, 0 EngineBaseID,'' Validate,0 VehicleTypeID, 0 EngineDesignationID, 0 EngineVersionID,
                        0 EngineVINID, 0 AspirationID, 0 CylinderHeadTypeID, 0 FuelTypeID, 0 FuelSystemDesignID, 0 FuelDeliveryTypeID, 0 FuelDeliverySubTypeID,
                        0 BodyNumDoorsID, 0 BodyTypeID, 0 BrakeABSID, 0 MfrBodyCodeID, 0 FrontBrakeID, 0 DriveTypeID, 0 SteeringSystemID, 0 TransmissionMfrCodeID,
                        0 TransmissionControlTypeID, 0 TransmissionNumSpeedsID, 0 TransmissionTypeID, 0 PartTypeID, 0 PositionID, 0 PowerOutputID, 
                        '' HorsePower, '' KilowattPower, 0 ValvesPerEngineID,'' ValvesPerEngine,0 IgnitionSystemTypeID, '' IgnitionSystemTypeName, 0 BedTypeID, '' BedTypeName,
                        0 WheelBaseID, '' WheelBase, '' WheelBaseMetric,0 FrontSpringTypeID, '' FrontSpringTypeName, 0 RearSpringTypeID, '' RearSpringTypeName, 0 SteeringTypeID,
                        '' SteeringTypeName, '' DisplayOrder, '' AssetName, '' AssetItemOrder, '' AssetItemRef,0 EngineMfrID, '' EngineMfrName,0 TransmissionMfrID,
                        '' TransmissionMfrName, 0 FuelSystemControlTypeID, '' FuelSystemControlTypeName, 0 TransElecControlledID, '' TransElecControlledName,
                        0 BedLengthID, '' BedLength, 0 BrakeSystemID, 0 RearBrakeID, 0 TransmissionBaseID, ISNULL(MfrLabel,'') AS MfrLabel 
                        FROM tools.CustomFitments_" + tenantID + @" WHERE TenantID = " + tenantID + @" AND PartID = " + partID + @"  
                        AND ISNULL(Action, '') = 'A' ";

                }
            }

            Query = @" DECLARE @flag1 INT  SELECT @flag1 = COUNT(*)FROM INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + flagTablename + @"' AND TABLE_SCHEMA = 'tools';
           IF ISNULL(@flag1,0)<> 0
               BEGIN
                
                SELECT  COUNT(*)  FROM (SELECT DISTINCT TenantID,PartID,Make,Year,Model,VehicleType,Region,SubModel,Liter,CC,CID, 
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
                BedLengthID,BedLength,BrakeSystemID,RearBrakeID,TransmissionBaseID, ISNULL(MfrLabel,'') AS MfrLabel 
                     FROM " + tablename + @" WHERE TenantID=" + tenantID + @" AND 
                         ISNULL(IsDeleted,0)!=1   AND ISNULL(isinvalid,0)!=" + valid + @"  AND PartID=" + partID + @" AND ISNULL(Action,'')='A'
                " + unionQuery + @") As tempTable; END ";
            return Query;
        }
        public static string read_unique_data_from_fitmentssaved(int PartID, int tenantID, string flagTablename, string tablename, int start, int size, string where, string order)
        {
            string Query = "", UnionQuery = "";
            if (string.IsNullOrWhiteSpace(order))
            {
                order = " ORDER BY Year ";
            }
            if (commonMethods.IsCustomFitmentsAccess(tenantID))
            {
                UnionQuery = @"  UNION
                                    SELECT DISTINCT TenantID,PartID,Make,Year,Model,VehicleType,Region,SubModel,Liter,CC,CID, 
                                    Cylinders,BlockType,EngBoreIn,EngBoreMetric,
                                    EngStrokeIn,EngStrokeMetric,EngineDesignationName,EngineVersion,EngineVIN,Aspiration,CylinderHeadTypeName,FuelTypeName,
                                    FuelSystemDesignName,FuelDeliveryTypeName,FuelDeliverySubTypeName,BodyNumDoors,BodyType,BrakeABSName,MfrBodyCodeName,
                                    FrontBrakeType,DriveTypeName,SteeringSystemName,TransmissionMfrCode,TransmissionControlTypeName,TransmissionNumSpeeds,
                                    TransmissionTypeName,PartType ,Qty,'' Position,Note,Action,'' UserID, '' isActive, '' isAdmin, '' Mapped, '' Resion,'' BrakeSystemName,
                                    RearBrakeType,0 BaseVehicleID,0 SubModelID, 0 RegionID, 0 EngineBaseID,'' Validate,0 VehicleTypeID, 0 EngineDesignationID, 0 EngineVersionID,
                                    0 EngineVINID, 0 AspirationID, 0 CylinderHeadTypeID, 0 FuelTypeID, 0 FuelSystemDesignID, 0 FuelDeliveryTypeID, 0 FuelDeliverySubTypeID,
                                    0 BodyNumDoorsID, 0 BodyTypeID, 0 BrakeABSID, 0 MfrBodyCodeID, 0 FrontBrakeID, 0 DriveTypeID, 0 SteeringSystemID, 0 TransmissionMfrCodeID,
                                    0 TransmissionControlTypeID, 0 TransmissionNumSpeedsID, 0 TransmissionTypeID, 0 PartTypeID, 0 PositionID, 0 PowerOutputID, 
                                    '' HorsePower, '' KilowattPower, 0 ValvesPerEngineID,'' ValvesPerEngine,0 IgnitionSystemTypeID, '' IgnitionSystemTypeName, 0 BedTypeID, '' BedTypeName,
                                    0 WheelBaseID, '' WheelBase, '' WheelBaseMetric,0 FrontSpringTypeID, '' FrontSpringTypeName, 0 RearSpringTypeID, '' RearSpringTypeName, 0 SteeringTypeID,
                                    '' SteeringTypeName, '' DisplayOrder, '' AssetName, '' AssetItemOrder, '' AssetItemRef,0 EngineMfrID, '' EngineMfrName,0 TransmissionMfrID,
                                    '' TransmissionMfrName, 0 FuelSystemControlTypeID, '' FuelSystemControlTypeName, 0 TransElecControlledID, '' TransElecControlledName,
                                    0 BedLengthID, '' BedLength, 0 BrakeSystemID, 0 RearBrakeID, 0 TransmissionBaseID, ISNULL(MfrLabel,'') AS MfrLabel 
                                    FROM tools.CustomFitments_" + tenantID + @" WHERE TenantID = " + tenantID + @" AND PartID = " + PartID + @" 
                                    AND ISNULL(Action, '') = 'A'  " + where + "";

                Query = @"DECLARE @total AS INT  DECLARE @flag1 INT  SELECT @flag1 = COUNT(*)FROM INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + flagTablename + @"' AND TABLE_SCHEMA = 'tools';             IF ISNULL(@flag1,0)<> 0     BEGIN
                                                   SELECT @total = COUNT(*)  FROM (SELECT DISTINCT TenantID,PartID,Make,Year,Model,VehicleType,Region,SubModel,Liter,CC,CID, 
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
                                    BedLengthID,BedLength,BrakeSystemID,RearBrakeID,TransmissionBaseID, ISNULL(MfrLabel,'') AS MfrLabel FROM " + tablename + @" WHERE TenantID = @TenantID AND PartID = @PartID AND ISNULL(Action, '') = 'A' AND ISNULL(IsInvalid, 0) = 0 AND ISNULL(IsDeleted, 0) = 0  " + where + UnionQuery + @" ) As tempTable

                                     SELECT DISTINCT @total AS Total, * FROM(
                                    SELECT ID, TenantID,PartID,Make,Year,Model,VehicleType,Region,SubModel,Liter,CC,CID, 
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
                                    BedLengthID,BedLength,BrakeSystemID,RearBrakeID,TransmissionBaseID, ISNULL(MfrLabel,'') MfrLabel FROM " + tablename + @" WHERE TenantID = @TenantID AND PartID = @PartID AND ISNULL(Action, '') = 'A' AND ISNULL(IsInvalid, 0) =0 AND ISNULL(IsDeleted, 0) =0  " + where + @"    
                                    UNION 
                                    SELECT DISTINCT -ID, TenantID,PartID,Make,Year,Model,VehicleType,Region,SubModel,Liter,CC,CID, 
                                    Cylinders,BlockType,EngBoreIn,EngBoreMetric,
                                    EngStrokeIn,EngStrokeMetric,EngineDesignationName,EngineVersion,EngineVIN,Aspiration,CylinderHeadTypeName,FuelTypeName,
                                    FuelSystemDesignName,FuelDeliveryTypeName,FuelDeliverySubTypeName,BodyNumDoors,BodyType,BrakeABSName,MfrBodyCodeName,
                                    FrontBrakeType,DriveTypeName,SteeringSystemName,TransmissionMfrCode,TransmissionControlTypeName,TransmissionNumSpeeds,
                                    TransmissionTypeName,PartType ,Qty,'' Position,Note,Action,'' UserID, '' isActive, '' isAdmin, '' Mapped, '' Resion,'' BrakeSystemName,
                                    RearBrakeType,0 BaseVehicleID,0 SubModelID, 0 RegionID, 0 EngineBaseID,'' Validate,0 VehicleTypeID, 0 EngineDesignationID, 0 EngineVersionID,
                                    0 EngineVINID, 0 AspirationID, 0 CylinderHeadTypeID, 0 FuelTypeID, 0 FuelSystemDesignID, 0 FuelDeliveryTypeID, 0 FuelDeliverySubTypeID,
                                    0 BodyNumDoorsID, 0 BodyTypeID, 0 BrakeABSID, 0 MfrBodyCodeID, 0 FrontBrakeID, 0 DriveTypeID, 0 SteeringSystemID, 0 TransmissionMfrCodeID,
                                    0 TransmissionControlTypeID, 0 TransmissionNumSpeedsID, 0 TransmissionTypeID, 0 PartTypeID, 0 PositionID, 0 PowerOutputID, 
                                    '' HorsePower, '' KilowattPower, 0 ValvesPerEngineID,'' ValvesPerEngine,0 IgnitionSystemTypeID, '' IgnitionSystemTypeName, 0 BedTypeID, '' BedTypeName,
                                    0 WheelBaseID, '' WheelBase, '' WheelBaseMetric,0 FrontSpringTypeID, '' FrontSpringTypeName, 0 RearSpringTypeID, '' RearSpringTypeName, 0 SteeringTypeID,
                                    '' SteeringTypeName, '' DisplayOrder, '' AssetName, '' AssetItemOrder, '' AssetItemRef,0 EngineMfrID, '' EngineMfrName,0 TransmissionMfrID,
                                    '' TransmissionMfrName, 0 FuelSystemControlTypeID, '' FuelSystemControlTypeName, 0 TransElecControlledID, '' TransElecControlledName,
                                    0 BedLengthID, '' BedLength, 0 BrakeSystemID, 0 RearBrakeID, 0 TransmissionBaseID, ISNULL(MfrLabel,'') AS MfrLabel 
                                    FROM tools.CustomFitments_" + tenantID + @" WHERE TenantID = " + tenantID + @" AND PartID = " + PartID + @" 
                                    AND ISNULL(Action, '') = 'A' " + where + @" 
                                    ) AS t " + order;

                if (size > 0)
                {
                    Query += " OFFSET((" + size + ") * ((" + start + ") - 1)) ROWS FETCH NEXT(" + size + ") ROWS ONLY";
                }

                Query += " END";


            }
            else
            {
                Query = @"DECLARE @total AS INT  DECLARE @flag1 INT  SELECT @flag1 = COUNT(*)FROM INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + flagTablename + @"' AND TABLE_SCHEMA = 'tools';             IF ISNULL(@flag1,0)<> 0     BEGIN
               SELECT @total = COUNT(*)  FROM (SELECT DISTINCT TenantID,PartID,Make,Year,Model,VehicleType,Region,SubModel,Liter,CC,CID, 
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
                                BedLengthID,BedLength,BrakeSystemID,RearBrakeID,TransmissionBaseID, ISNULL(MfrLabel,'') AS MfrLabel FROM " + tablename + @" WHERE TenantID = @TenantID AND PartID = @PartID AND ISNULL(Action, '') = 'A' AND ISNULL(IsInvalid, 0) = 0 AND ISNULL(IsDeleted, 0) = 0  " + where + @" ) As tempTable

                                 SELECT DISTINCT @total AS Total,MAX(ID) AS ID, TenantID,PartID,Make,Year,Model,VehicleType,Region,SubModel,Liter,CC,CID, 
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
                                BedLengthID,BedLength,BrakeSystemID,RearBrakeID,TransmissionBaseID, ISNULL(MfrLabel,'') MfrLabel FROM " + tablename + @" WHERE TenantID = @TenantID AND PartID = @PartID AND ISNULL(Action, '') = 'A' AND ISNULL(IsInvalid, 0) =0 AND ISNULL(IsDeleted, 0) =0  " + where + @"    GROUP BY   
                                 TenantID,PartID,Make,Year,Model,VehicleType,Region,SubModel,Liter,CC,CID, 
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
                                BedLengthID,BedLength,BrakeSystemID,RearBrakeID,TransmissionBaseID, MfrLabel " + order;

                if (size > 0)
                {
                    Query += " OFFSET((" + size + ") * ((" + start + ") - 1)) ROWS FETCH NEXT(" + size + ") ROWS ONLY";
                }

                Query += " END";

            }

            return Query;
        }
        public static string GetTotalFitmentWalmartQueryForExport(int tenantID)
        {
            string tablename = "tools.FitmentsSaved_" + tenantID;
            string flagtable = "FitmentsSaved_" + tenantID;
            string Query = @" IF NOT EXISTS (SELECT * FROM   INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + flagtable + @"'AND TABLE_SCHEMA = 'tools')
            BEGIN
               SELECT 0 AS COUNT
            END
            ELSE
            BEGIN
               SELECT Count(ID) FROM  " + tablename + @" WHERE TenantID=" + tenantID + @" AND ISNULL(isDeleted,0) = 0 AND ISNULL(BaseVehicleID,0)>0 AND ISNULL(Action,'')  = 'A' AND ISNULL(isinvalid,0) = 0 ;
            END";

            return Query;
        }
    }
}