

import UIKit
import SkeletonView

import ShimmerSwift
import CocoaMQTT
typealias v2CB = (_ infoToReturn :String) ->()
class LuckViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var similarlabel: UILabel!
    @IBOutlet weak var upperview: UIView!
    @IBOutlet weak var checkview: UIView!
    @IBOutlet weak var tv_nft_title: UILabel!
    @IBOutlet weak var tv_nft_value: UILabel!
    @IBOutlet weak var tv_nft_desc: UILabel!
    @IBOutlet var luck_view: UIView!
    @IBOutlet var sV: UIView!
    @IBOutlet weak var lowerview: UIView!
    
//    @IBOutlet weak var ans_nft_view: UIView!
    var yet : String?
    var redirecturl = "https://rarible.com/token/0x60f80121c31a0d46b5279700f9df786054aa5ee5:1103811?tab=details"
    
    var publishstringdaw : String?
    var luckmqtt: CocoaMQTT?
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    var gitimages : [UIImage] = []
    var cell_title : [String] = []
    var cell_value : [String] = []
    var cell_desc : [String] = []
    var resultanswer : String?

//    @IBOutlet weak var resultstackview: UIStackView!
    var imagedata:Data? = nil
    var completionBlock:v2CB?
   @IBOutlet private var myCOll:UICollectionView!


    @IBOutlet weak var resultimage: UIImageView!
    @IBOutlet weak var resultLabel1Stack: UIStackView!
   
    var resultComp : ((String) -> Void)?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    func pushoutimage(urlonly : String ) -> UIImage{
                return (UIImage(named: "redxx")!)

    }
    
    @objc func tapped() {
        print("jhhj")
        guard let settingsUrl = URL(string: redirecturl) else {
          return
    }

        if UIApplication.shared.canOpenURL(settingsUrl) {
          UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                                                     print("Settings opened: \(success)") // Prints true
                                                                    })
        }
        
    }
    @objc func celltapped() {
        guard let settingsUrl = URL(string: "https://opensea.io/assets/0x495f947276749ce646f68ac8c248420045cb7b5e/84032746108682377077311182689636944560742163099864638274822591485858937831425") else {
          return
    }

        if UIApplication.shared.canOpenURL(settingsUrl) {
          UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                                                     print("Settings opened: \(success)") // Prints true
                                                                    })
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        resultimage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
//        LoadingShimmer.startCovering(resultstackview, with: ["resultimage","tv_nft_title","tv_nft_value","tv_nft_desc"])
        
//        LoadingShimmer.startCovering(view, with: nil)
//        LoadingShimmer.startCovering(dummyresultimageview, with: nil)
        
   
//        view.showAnimatedGradientSkeleton()
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.loaditems()
        }
        
//        lowerview.layer.roundCorners(corners: [.topRight, .topLeft], radius: 10)

        lowerview.layer.cornerRadius = 10
        lowerview.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        tv_nft_desc.useFontLineHeight = false
        tv_nft_title.useFontLineHeight = false
        tv_nft_value.useFontLineHeight = false
        let gradientuh = SkeletonGradient(baseColor: UIColor.darkGray)

        checkview.showAnimatedGradientSkeleton(usingGradient: gradientuh)
//        similarlabel.showAnimatedGradientSkeleton()

        
//        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
//        let mqtt = CocoaMQTT(clientID: "001", host: "hairdresser.cloudmqtt.com", port: 35488)
//        mqtt.username = "pcxwoore"
//        mqtt.password = "hhZmNsQrWfBW"
//        mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
//        mqtt.keepAlive = 60
//        mqtt.delegate = self
//        mqtt.connect()
            
//        let image = UIImage(data: imagedata!)
//
//        let imageView = UIImageView(image: image)
//        imageView.contentMode = .scaleAspectFill
//        imageView.frame = view.bounds
//        view.addSubview(imageView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
    }
  
       
       // MARK: - UICollectionViewDataSource protocol
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
       
       // tell the collection view how many cells to make
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return self.gitimages.count
       }
       
    
    
    
       // make a cell for each cell index path
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           
           // get a reference to our storyboard cell
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? MyCollectionViewCell
           
        //        let imageSize = model.images[indexPath.row].size
           // Use the outlet in our custom class to get a reference to the UILabel in the cell
            cell?.img.image = self.gitimages[indexPath.item]
        cell?.cell_title.text = self.cell_title[indexPath.item]
        cell?.cell_descc.text = self.cell_desc[indexPath.item]
        cell?.layer.cornerRadius = 10
        cell?.img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(celltapped)))

        // The row value is the same as the index of the desired text within the array.
//           cell?.backgroundColor = UIColor.cyan // make cell more visible in our example project
           
           return cell!
       }
       
       
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           // handle tap events
           print("You selected cell #\(indexPath.item)!")
        
        celltapped()
       }
    
    func returnFirstValue(sender: UIButton) {
            guard let cb = completionBlock else {return}
        cb("any value")
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //return UICollectionViewFlowLayout.automaticSize
        CGSize(width: self.myCOll.frame.width/2.1, height: self.myCOll.frame.height)
    }
    
    
    //MARK: - CollectionView UI Setup
   
    @objc func doSomethingAfterNotified( notification: Notification) {
       print("I've been notified")
        if let value = notification.userInfo?["value"] as? String {
            print("came",value)
            //545826199
            //427557822
            var image : UIImage?
            upperview.hideSkeleton(transition: .crossDissolve(0.25))
            gitimages.removeAll()
            cell_title.removeAll()
            cell_value.removeAll()
            cell_desc.removeAll()            //lemon daw
            if ( value == "545826199"){
                
                print("if condition 1")
                image = UIImage(named: "nft_lmnz")
                tv_nft_value.text = "Abstract polygonal lemon."
                tv_nft_title.text = "NIL"

                redirecturl = "https://rarible.com/token/0x60f80121c31a0d46b5279700f9df786054aa5ee5:1103811?tab=details";                tv_nft_desc.text = "Hand-made without the use of plug-ins."

                //cell deatails
                
                gitimages.append(UIImage(named: "poly1")!)
                gitimages.append(UIImage(named: "poly2")!)
                gitimages.append(UIImage(named: "applepoly")!)
                gitimages.append(UIImage(named: "banaana")!)
                gitimages.append(UIImage(named: "orangeuhhh")!)
                
                cell_title.append("Abstract polygonal mandarin")
                cell_title.append("MY pineapple")
                cell_title.append("Abstract polygonal red apple")
                cell_title.append("Abstract polygonal banana")
                cell_title.append("Abstract polygonal orange")
        //        THE FIRST TOY IN THE TOYZ SER-IES.
                cell_desc.append("Hand-made without the use of plug-ins.")
                cell_desc.append("Hand-made without the use of plug-ins.")
                cell_desc.append("Hand-made without the use of plug-ins.")
                cell_desc.append("Hand-made without the use of plug-ins.")
                cell_desc.append("Hand-made without the use of plug-ins. After purchasing you will get access to jpg and eps version. ")
        //        THE FIRST TOY IN THE TOYZ SER-IES.
                
                
                
             
                
                
            }
            //potato
            else if( value == "427557822" ){
                
                print("if condition 2")
                image = UIImage(named: "nft_potato_toy")
//                image = UIImage(named: "nft_potato_toy")

                redirecturl = "https://rarible.com/token/0x495f947276749ce646f68ac8c248420045cb7b5e:84032746108682377077311182689636944560742163099864638274822591486958449459201?tab=owners";
                tv_nft_value.text = "Potato Head, By MENJi"
                tv_nft_title.text = "0.001ETH"
                tv_nft_desc.text = "I'm getting old. I'm the last potato head, take care of me. Look at you, collecting toys."
                
                //cell details
                
                gitimages.append(UIImage(named: "potatoalterr")!)
                gitimages.append(UIImage(named: "potato_alt")!)
                gitimages.append(UIImage(named: "potato_altt")!)
                gitimages.append(UIImage(named: "check")!)
                gitimages.append(UIImage(named: "notpotato")!)
                
                cell_title.append("POTATO HEAD 1/4")
                cell_title.append("POTATO HEAD 3/4")
                cell_title.append("POTATO HEAD 4/4")
                cell_title.append("BLOSSOM - ORANGE")
                cell_title.append("BLOSSOM - YELLOW")
        //        THE FIRST TOY IN THE TOYZ SER-IES.
                cell_desc.append("THE FIRST TOY IN THE TOYZ SER-IES. LOOK AT YOU, COLLECTING TOYS")
                cell_desc.append("HOW ARE YOU LIKING THE GREEN? YOU DON'T? GUESS WHAT, LOOK AT MY FINGER. - LOOK AT YOU, COLLECTING TOYS :)(:")
                cell_desc.append("IT'S LOOKING GOOD IN HEAVEN, BUT POTATO HEAD IS STILL A BIT SALTY. LOOK AT YOU, COLLECTING TOYS :)(: ")
                cell_desc.append("ORANGE - Joy, enthusiasm, creativity, success, encouragement, change, determination.")
                cell_desc.append("ELLOW - Wisdom, Intellect, Enthusiasm, Joy, Optimism")
        //        THE FIRST TOY IN THE TOYZ SER-IES.
                
                
            }
            else if( value == "45454545" ){
                
                redirecturl = "https://rarible.com/token/0x60f80121c31a0d46b5279700f9df786054aa5ee5:1103811?tab=details";
                print("if condition 3 ")
                image = UIImage(named: "nft_cyphernet")
                tv_nft_value.text = "Potato Head, By MENJi"
                tv_nft_title.text = "0.001ETH"
                tv_nft_desc.text = "I'm getting old. I'm the last potato head, take care of me. Look at you, collecting toys."
            }
            else if( value == "12121212" ){
                redirecturl = "https://rarible.com/token/0x60f80121c31a0d46b5279700f9df786054aa5ee5:1103811?tab=details";
                print("if condition4")
                image = UIImage(named: "nft_evolo")
                tv_nft_value.text = "Potato Head, By MENJi"
                tv_nft_title.text = "0.001ETH"
                tv_nft_desc.text = "I'm getting old. I'm the last potato head, take care of me. Look at you, collecting toys."
            }
            resultimage.image = image

            
            
    //        pan()
            self.myCOll.delegate = self
            self.myCOll.dataSource = self
            self.myCOll.register(UINib(nibName: "MyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
            
            self.resultComp = { string in
                print("controller",string)
            }
            

            
    //          <---set the fucking captured image ---->
    //        let image = UIImage(data: imagedata!)
    //        resultimage.image = image
            
            

            
            let cl = UICollectionViewFlowLayout()
    //        cl.itemSize = CGSize(width: self.myCOll.frame.width/3, height: 50)
            cl.scrollDirection = .vertical
            cl.minimumLineSpacing = 10.0
            myCOll.setCollectionViewLayout(cl, animated: true)
        }
     }
    func loaditems()
    {
        checkview.layer.cornerRadius = 10.0
        
//        viewToRound.layer.mask = maskLayer

        
        //        checkview.backgroundColor = UIColor.red
        
        //        let shimmerView = ShimmeringView(frame: CGRect(x: 0, y: 0, width: luck_view.bounds.width, height: luck_view.bounds.height))
        //        view.addSubview(shimmerView)
        
        //        shimmerView.isShimmering = true
        
        print("working" , (resultanswer!))
        //        resultimage.image = UIImage(named: "redxx")
        //        resultimage.setImageColor(color: UIColor.purple)
        //        LoadingShimmer.startCovering(resultimage, with: nil)
        
        //        tv_nft_desc.setlabelshimmer()
        //        tv_nft_value.setlabelshimmer()
        //        tv_nft_title.setlabelshimmer()
        
        //        // pretty easy if you know the code to draw a gradient
        //        let gradientLayer = CAGradientLayer()
        //        // if you are following along, make sure to use cgColor
        //        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        //        gradientLayer.locations = [0, 0.5, 1]
        //        gradientLayer.frame = tv_nft_desc.frame
        //        let angle = 45 * CGFloat.pi / 180
        //        gradientLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        //        tv_nft_desc.layer.mask = gradientLayer
        //
        //        //animation
        //        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        //        animation.duration = 2
        //        animation.fromValue = -view.frame.width
        //        animation.toValue = view.frame.width
        //        animation.repeatCount = Float.infinity
        //
        //        gradientLayer.add(animation, forKey: "doesn'tmatterJustSomeKey")
        
        //        tv_nft_desc.showSkeleton()
        
        print(luckmqtt?.connState.description)
        let compressedData = Data (UIImage(data: imagedata!)!.jpegData(compressionQuality: 0.2)!)
        print("compression done")
        let url = URL(string: "http://aioty.in/scopex/upload.php?id="+yet!)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let parameters: [String: Any] = [
            "imgBase64": compressedData.base64EncodedString(),
        ]
        request.httpBody = parameters.percentEncoded()
        
        let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
            
                
                
                
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
                }
                
                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    return
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString)")
                
                
                publishstringdaw = "http://aioty.in/scopex/image_data/"+yet!+".jpg"
                print(publishstringdaw)
                luckmqtt!.publish("scopex1", withString: yet!+",get,"+publishstringdaw!)
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(doSomethingAfterNotified),
                                                       name: NSNotification.Name(rawValue: "myNotificationKey"),
                                                       object: nil)
                
            
        }
        
        task.resume()
        
        /*
         HTTP.request(.POST, "http://aioty.in/scopex/upload.php?id="+yet!, params: ["imgBase64": compressedData.base64EncodedString() ]) { [self] response in
         //            response.response
         //            response.data
         /*
         if let error = response.error {
         print(error.localizedDescription)
         return
         }
         
         guard let data = response.data else {
         print("fdsf")
         return
         }
         print(String(decoding: data, as: UTF8.self))
         */
         
         
         publishstringdaw = "http://aioty.in/scopex/image_data/"+yet!+".jpg"
         print(publishstringdaw)
         
         //            luckmqtt?.publish("check", withString: "working")
         luckmqtt!.publish("scopex1", withString: yet!+",get,"+publishstringdaw!)
         NotificationCenter.default.addObserver(self,
         selector: #selector(doSomethingAfterNotified),
         name: NSNotification.Name(rawValue: "myNotificationKey"),
         object: nil)
         
         }
         */
        
    }
}

extension UILabel {
    func setlabelshimmer() {
//        let funbackgroundLayer = UIView(frame: self.frame)
//        funbackgroundLayer.backgroundColor = UIColor.red
//        self.addSubview(funbackgroundLayer)
        
        // pretty easy if you know the code to draw a gradient
        let gradientLayer = CAGradientLayer()
        // if you are following along, make sure to use cgColor
        gradientLayer.colors = [UIColor.white.cgColor,UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor,UIColor.white.cgColor]
        gradientLayer.locations = [0,0.2, 0.5, 0.8,1]
        gradientLayer.frame.size.width = UIScreen.main.bounds.width
        gradientLayer.frame.size.height = UIScreen.main.bounds.height
        let angle = 45 * CGFloat.pi / 180
        gradientLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        self.layer.mask = gradientLayer
        
        //animation
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = 2
        animation.fromValue =  -UIScreen.main.bounds.width
        animation.toValue = UIScreen.main.bounds.width
        animation.repeatCount = Float.infinity
        
        gradientLayer.add(animation, forKey: "doesn'tmatterJustSomeKey")
    }
    
}


extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}
extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension CALayer {
  func roundCorners(corners: UIRectCorner, radius: CGFloat) {
    let maskPath = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))

    let shape = CAShapeLayer()
    shape.path = maskPath.cgPath
    mask = shape
  }
}
