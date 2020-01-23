import UIKit

class DeviceTableViewCell: UITableViewCell {

    //IBOutlet references.
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceUuid: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
