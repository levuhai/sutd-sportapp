// From: https://forums.developer.apple.com/thread/13580

extension String {  
  
    var lastPathComponent: String {
        get {  
            return (self as NSString).lastPathComponent  
        }  
    }
    
    var pathExtension: String {
        get {
            return (self as NSString).pathExtension  
        }  
    }
    
    var stringByDeletingLastPathComponent: String {
        get {
            return (self as NSString).deletingLastPathComponent  
        }  
    }
    
    var stringByDeletingPathExtension: String {
        get {
            return (self as NSString).deletingPathExtension  
        }  
    }
    
    var pathComponents: [String] {
        get {
            return (self as NSString).pathComponents  
        }  
    }  
  
    func stringByAppendingPathComponent(_ path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)  
    }
  
    func stringByAppendingPathExtension(_ ext: String) -> String? {
        let nsSt = self as NSString
        return nsSt.appendingPathExtension(ext)  
    }  
}
