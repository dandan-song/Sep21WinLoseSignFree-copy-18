/*
* Copyright (c) 2013-2016 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import SceneKit

let UIColorList:[UIColor] = [
  UIColor.blackColor1(),
  UIColor.white,
  UIColor.redColor1(),
  UIColor.limeColor(),
  UIColor.blueColor1(),
  UIColor.yellowColor1(),
  UIColor.cyanColor1(),
  UIColor.silverColor(),
  UIColor.gray,
  UIColor.maroonColor(),
  UIColor.oliveColor(),
  UIColor.brownColor1(),
  UIColor.green,
  UIColor.lightGray,
  UIColor.magentaColor1(),
  UIColor.orange,
  UIColor.purple,
  UIColor.tealColor()
]

extension UIColor {
  
  public static func random() -> UIColor {
    let maxValue = UIColorList.count
    let rand = Int(arc4random_uniform(UInt32(maxValue)))
    return UIColorList[rand]
  }
  
    public  static func whiteColor1 () -> UIColor {
        return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
    }
    public static func blackColor1() -> UIColor {
        return UIColor(red: 211/255, green: 218/255, blue: 249/255, alpha: 1.0)
    }
    public static func redColor1() -> UIColor {
        return UIColor(red: 252/255, green: 193/255, blue: 197/255, alpha: 1.0)
    }
    public static func blueColor1() -> UIColor {
        return UIColor(red: 225/255, green: 241/255, blue: 247/255, alpha: 1.0)
    }
    public static func yellowColor1() -> UIColor {
        return UIColor(red: 233/255, green: 242/255, blue: 133/255, alpha: 1.0)
    }
    public static func cyanColor1() -> UIColor {
        return UIColor(red: 250/255, green: 209/255, blue: 209/255, alpha: 1.0)
    }
    public static func brownColor1() -> UIColor {
        return UIColor(red: 249/255, green: 217/255, blue: 180/255, alpha: 1.0)
    }
    public static func magentaColor1() -> UIColor {
        return UIColor(red: 249/255, green: 223/255, blue: 247/255, alpha: 1.0)
    }
    
    
  public static func limeColor() -> UIColor {
    return UIColor(red: 195/255, green: 1, blue: 216/255, alpha: 1.0)
  }
  
  public static func silverColor() -> UIColor {
    return UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1.0)
  }
  
  public static func maroonColor() -> UIColor {
    return UIColor(red: 1.0, green: 196/255, blue: 133/255, alpha: 1.0)
  }
  
  public static func oliveColor() -> UIColor {
    return UIColor(red: 99/255, green: 196/255, blue: 133/255, alpha: 1.0)
  }
  
  public static func tealColor() -> UIColor {
    return UIColor(red: 99/255, green: 196/255, blue: 216/255, alpha: 1.0)
  }
  
  public static func navyColor() -> UIColor {
    return UIColor(red: 101/255, green: 160/255, blue: 252/255, alpha: 1.0)
  }
}
