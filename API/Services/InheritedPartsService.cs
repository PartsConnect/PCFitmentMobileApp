using Dapper;
using PCFitment_API.Models;
using System.Data.SqlClient;
using System.Text;
using PCFitment_API.Models;
using TestRestAPI.Models.Utilities;
using PartsConnectWebTools.Models.Custom;
using PartsConnectWebTools.Helpers;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static System.Runtime.InteropServices.JavaScript.JSType;
using System.Data;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Mvc;


namespace PCFitment_API.Services
{
    public class InheritedPartsService
    {
        public MDLInheritedParts GetInheritedPartDetails(Int64 partID = 0, Int64 TenantID = 0)
        {
            // Initialize mDLInheritedParts
            MDLInheritedParts mDLInheritedParts = new MDLInheritedParts();

            // Check if partID and TenantID are valid
            if (partID > 0 && TenantID > 0)
            {
                // Fetch the inherited part details
                mDLInheritedParts = PartsHelper.GetInheritPartDetailById(partID, TenantID);

                // If details are found, fetch the fitments count
                if (mDLInheritedParts != null)
                {
                    mDLInheritedParts.Fitments = PartsHelper.GetFitmetnCount(partID, TenantID);
                }
            }

            // If mDLInheritedParts is still null, return a new instance
            if (mDLInheritedParts == null)
            {
                mDLInheritedParts = new MDLInheritedParts();
            }

            return mDLInheritedParts;
        }

        public string AddInheritedPart(MDLInheritedParts mDLInheritedParts)
        {
            string tenantID = mDLInheritedParts.TenantID;
            mDLInheritedParts.NewPartNumber = Regex.Replace(mDLInheritedParts.NewPartNumber.Trim(), @"[^\u0000-\u007F]+", string.Empty);

            bool Isvalid = true;
            try
            {
                if (PartsHelper.CheckPartsTable(tenantID))
                {
                    if (string.IsNullOrWhiteSpace(mDLInheritedParts.NewASIN))
                    {
                        Isvalid = false;
                    }

                    if (!string.IsNullOrWhiteSpace(mDLInheritedParts.NewPartNumber))
                    {
                        // Define the regular expression for invalid characters
                        var reg = @"[;[\]{}~|,%!$*^\\?']";

                        // Check if the NewPartNumber contains invalid characters
                        if (System.Text.RegularExpressions.Regex.IsMatch(mDLInheritedParts.NewPartNumber, reg))
                        {
                            // Handle the case where the NewPartNumber contains invalid characters
                            return "F" + "|" + "PartNumber contain invalid character.";
                        }
                        else
                        {
                            // Fetch the part number using the helper
                            string PartNumber = PartsHelper.GetPartNumber(tenantID, mDLInheritedParts.NewPartNumber);

                            // If the part number is already present in the database
                            if (!string.IsNullOrWhiteSpace(PartNumber))
                            {
                                return "F" + "|" + "Part Number is already added in your database.";
                            }
                        }
                    }
                    else
                    {
                        return "F" + "|" + "Please Enter Part Number!";
                    }

                    if (Isvalid)
                    {
                        //Get All Detail Of Parent PartNumber
                        DataTable PartDetail = PartsHelper.GetPartNumberDetails(tenantID, mDLInheritedParts.ParentPartID);

                        //Check ParentPartID, IsInitalSubmission, LastVariationSubmissionDate column are Available in Tools.part table if not then Add columns.
                        PartsHelper.AddParantIdcolnm(Convert.ToInt32(tenantID));
                        if (PartDetail != null && PartDetail.Rows.Count > 0)
                        {
                            mDLInheritedParts.ManufactureLabel = Convert.ToString(PartDetail.Rows[0]["ManufactureLabel"]);
                            mDLInheritedParts.PartDescription = Convert.ToString(PartDetail.Rows[0]["PartDescription"]);
                            mDLInheritedParts.PartTerminologyID = Convert.ToString(PartDetail.Rows[0]["PartTerminologyID"]);
                            mDLInheritedParts.BrandID = Convert.ToString(PartDetail.Rows[0]["BrandID"]);
                            int AddPart = PartsHelper.AddChildPart(tenantID, mDLInheritedParts.NewPartNumber, mDLInheritedParts.NewASIN, mDLInheritedParts.ManufactureLabel, mDLInheritedParts.PartDescription, mDLInheritedParts.PartTerminologyID, mDLInheritedParts.InheritBrandID, mDLInheritedParts.ParentPartID);

                            if (AddPart > 0)
                            {
                                return "S" + "|" + "Part Number is added!";
                            }
                            else
                            {
                                return "F" + "|" + "Part Number is not added!";
                            }
                        }
                        else
                        {
                            return "F" + "|" + "Part Number is not added!";
                        }
                    }
                    else
                    {
                        return "F" + "|" + "Please Enter ASIN!";
                    }
                }
                else
                {
                    return "F" + "|" + "Part Number is not added!";
                }

            }
            catch (Exception ex)
            {
                return "F" + "|" + ex.Message + ", Something went wrong! Please contact to system admin!";
            }

        }

        public IEnumerable<MDLInheritedParts> GetInheritedPartList(Int64 partID = 0, Int64 TenantID = 0)
        {
            // Initialize mDLInheritedParts with an empty list
            IEnumerable<MDLInheritedParts> mDLInheritedParts = new List<MDLInheritedParts>();

            // Check if partID and TenantID are valid
            if (partID > 0 && TenantID > 0)
            {
                // Check if the parent part column exists
                bool isParentPartColExist = PartsHelper.checkParentColumn(TenantID);

                // If the parent part column doesn't exist, add it
                if (!isParentPartColExist)
                {
                    PartsHelper.AddParantIdcolnm(TenantID);
                }

                // Retrieve the inherited parts
                mDLInheritedParts = PartsHelper.GetAllInheritedParts(TenantID, partID);
            }

            return mDLInheritedParts;
        }


    }
}
