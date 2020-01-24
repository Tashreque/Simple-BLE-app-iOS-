import UIKit

class DeviceTableViewCell: UITableViewCell {

    //IBOutlet references.
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceUuid: UILabel!
    @IBOutlet weak var peripheralDisconnectButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func disconnectButtonTapped(_ sender: UIButton) {
        // Called when the device corresponding to this cell should get disconnected.
    }
}
