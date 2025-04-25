using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.ToolTip;
using System.Globalization;
using System.Windows.Forms;

namespace Project3
{
    public class Candlestick
    {
        public DateTime Date { get; set; }
        public string Name;
        public Decimal Open { get; set; }
        public Decimal Close{ get; set; }
        public Decimal Low { get; set; }
        public Decimal High { get; set; }
        public ulong Volume { get; set; }

        public Candlestick()
        {
        }


        public Candlestick(DateTime date, decimal open, decimal high, decimal low, decimal close, ulong volume)
        {
            Date = date;
            Open = open;
            High = high;
            Low = low;
            Close = close;
            Volume = volume;
        }
        public Candlestick(string data)
        {
            //clean the string so there are no quotation marks in the date. 
            data = data.Replace("\"", "");
            //delimiters to split the data string
            var delimiters = new char[] { ',', '/'};
            //split string into array of string
            var values = data.Split(delimiters, StringSplitOptions.RemoveEmptyEntries);
            if (values.Length != 6)
            {
                throw new ArgumentException("Invalid format");
            }
            //check if datetime is acceptable
            if (!DateTime.TryParse(values[0].Trim(), out DateTime parsedDate))
            {
                //Console.WriteLine($"Raw Input: '{values[0].Trim()}' (Length: {values[0].Trim().Length})");

                throw new ArgumentException($"Raw Input: '{values[0].Trim()}' (Length: {values[0].Trim().Length})");
            }
            //assign parsed string to each variable of the candlestick
            Date = parsedDate;
            Open = Math.Round(decimal.Parse(values[1]), 2);
            High = Math.Round(decimal.Parse(values[2]), 2);
            Low = Math.Round(decimal.Parse(values[3]), 2);
            Close = Math.Round(decimal.Parse(values[4]), 2);
            Volume = ulong.Parse(values[5]);
        }
    }
}
