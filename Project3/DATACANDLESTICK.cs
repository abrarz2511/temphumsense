using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Project3
{
    internal class DATACANDLESTICK
    {
        public List<Candlestick> ReadCandlesticksFromFile(string filePath)
        {
            var candlesticks = new List<Candlestick>();
            using (StreamReader sr = new StreamReader(filePath, Encoding.UTF8))
            {
                //skip the header line
                var header = sr.ReadLine();

                //read file until stream reader is null
                while (!sr.EndOfStream)
                {
                    //create a new candlestick for each line of the file
                    string line = sr.ReadLine();
                    line.Trim();
                    candlesticks.Add(new Candlestick(line));
                }
            }
            //return list of candlesticks
            return candlesticks;
        }
    }
}
