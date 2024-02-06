using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PartsConnectWebTools.Models.Custom
{
    public partial class PartDisplay
    {
        public string PartTypeName { get; set; }
        public int Isinvalid { get; set; }
        public int YearFrom { get; set; }
        public int YearTo { get; set; }
        public int Make { get; set; }
        public int Vehicle { get; set; }
        public int CategoryID { get; set; }
        public int SubCategoryID { get; set; }
        public int Model { get; set; }
        public string ColumnName { get; set; }
        public int ColumnID { get; set; }
        public int[] Columnsid { get; set; }
        public int[] Columnsid2 { get; set; }
        public int[] Columnsid3 { get; set; }
        public int[] Removeid { get; set; }
        public int Total { get; set; }
        public int RemoveColID { get; set; }
        public int SaveID { get; set; }
      //  public string BrandID { get; set; }
        public string SKU { get; set; }
        public int TotalFitments { get; set; }
        public int fitmentcount { get; set; }
        public int PartTerminologyID { get; set; }
        //New Vehicle Properties
        public int NVYearFrom { get; set; }
        public int NVYearTo { get; set; }
        public int NVMake { get; set; }
        public int NVVehicle { get; set; }
        public int NVModel { get; set; }
        public string RangeFrom { get; set; }
        public string RangeTo { get; set; }
    }
}