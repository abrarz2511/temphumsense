using System;
using System.Collections.Generic;

namespace Project3
{
    public class Smartcandlestick
    {
        public bool peak { get; set; }
        public bool valley { get; set; }
        public int index { get; set; }
        public int lMargin { get; set; }
        public int rMargin { get; set; }
        public DateTime date { get; set; }

        public Smartcandlestick()
        {
            peak = false;
            valley = false;
            index = -1;
            lMargin = -1;
            rMargin = -1;
        }

        public Smartcandlestick(bool Peak, bool Valley, int Index, int LMargin, int RMargin)
        {
            peak = Peak;
            valley = Valley;
            index = Index;
            lMargin = LMargin;
            rMargin = RMargin;
        }
    }

    public class Wave
    {
        public decimal startPrice { get; set; }
        public decimal endPrice { get; set; }
        public int startIndex { get; set; }
        public int endIndex { get; set; }
        public bool up { get; set; }
        public bool down { get; set; }
        public DateTime startDate { get; set; }
        public DateTime endDate { get; set; }
        public string displayDate { get; set; }

        public Wave()
        {
            startDate = DateTime.MinValue;
            endDate = DateTime.MinValue;
            startIndex = 0;
            endIndex = 0;
            up = false;
            down = false;
            displayDate = string.Empty;
        }
    }
}