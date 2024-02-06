using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{

    public class MDLGetMostRecentExport
    {
        public string ExportDate { get; set; }
        public string ExportType { get; set; }
        public string strFilePath { get; set; }

    }

    public class MDLGetMostRecentExportInfo
    {
        public List<MDLGetMostRecentExport> MostRecentExportsList { get; set; }

        public MDLGetMostRecentExportInfo()
        {
            MostRecentExportsList = new List<MDLGetMostRecentExport>();
        }

    }
}
