colortest()
{
    list rows = [];
    rows += ["<span class=\\'color_0\\'>color_00</span>|Black|<span class=\\'color_0\\'>██████████</span>"];
    rows += ["<span class=\\'color_1\\'>color_01</span>|Red|<span class=\\'color_1\\'>██████████</span>"];
    rows += ["<span class=\\'color_2\\'>color_02</span>|Green|<span class=\\'color_2\\'>██████████</span>"];
    rows += ["<span class=\\'color_3\\'>color_03</span>|Yellow|<span class=\\'color_3\\'>██████████</span>"];
    rows += ["<span class=\\'color_4\\'>color_04</span>|Blue|<span class=\\'color_4\\'>██████████</span>"];
    rows += ["<span class=\\'color_5\\'>color_05</span>|Magenta|<span class=\\'color_5\\'>██████████</span>"];
    rows += ["<span class=\\'color_6\\'>color_06</span>|Cyan|<span class=\\'color_6\\'>██████████</span>"];
    rows += ["<span class=\\'color_7\\'>color_07</span>|White|<span class=\\'color_7\\'>██████████</span>"];
    rows += ["<span class=\\'color_8\\'>color_08</span>|Bright_Black|<span class=\\'color_8\\'>██████████</span>"];
    rows += ["<span class=\\'color_9\\'>color_09</span>|Bright_Red|<span class=\\'color_9\\'>██████████</span>"];
    rows += ["<span class=\\'color_10\\'>color_10</span>|Bright_Green|<span class=\\'color_10\\'>██████████</span>"];
    rows += ["<span class=\\'color_11\\'>color_11</span>|Bright_Yellow|<span class=\\'color_11\\'>██████████</span>"];
    rows += ["<span class=\\'color_12\\'>color_12</span>|Bright_Blue|<span class=\\'color_12\\'>██████████</span>"];
    rows += ["<span class=\\'color_13\\'>color_13</span>|Bright_Magenta|<span class=\\'color_13\\'>██████████</span>"];
    rows += ["<span class=\\'color_14\\'>color_14</span>|Bright_Cyan|<span class=\\'color_14\\'>██████████</span>"];
    rows += ["<span class=\\'color_15\\'>color_15</span>|Bright_White|<span class=\\'color_15\\'>██████████</span>"];
    
    list headers = ["class", "name", "color"];
    printText(tabulate(headers, rows));
}
