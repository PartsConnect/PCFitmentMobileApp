using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{

    public class MDLGetHelpVideosDetails
    {
        public string App_Help_Videosld { get; set; }
        public string VideoTitle { get; set; }
        public string LabelTitle { get; set; }
        public string VideoImage { get; set; }
        public string VideoLink { get; set; }
        public string IsActive { get; set; }
    }
}
