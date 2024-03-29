import UIKit

class RegisterView: UIView {
    @IBOutlet weak var emailTextField: AuthTextField!
    @IBOutlet weak var passwordTextField: AuthTextField!
    @IBOutlet weak var registerButton: BasicButton!
    @IBOutlet weak var errorLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareView()
    }

    private func prepareView() {
        emailTextField.titleText = "Email:"
        passwordTextField.titleText = "Password:"

        errorLabel.font = UIFont.regular14
        clearErrors()
    }

    func setError(to field: AuthTextField) {
        field.setState(.error)
    }

    func setErrorText(_ text: String) {
        errorLabel.text = text
        errorLabel.isHidden = false
    }

    func clearErrors() {
        errorLabel.text = ""
        errorLabel.isHidden = true

        emailTextField.setState(.normal)
        passwordTextField.setState(.normal)
    }
}
