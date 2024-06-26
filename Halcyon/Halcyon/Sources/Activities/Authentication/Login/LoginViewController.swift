import UIKit

class LoginViewController: ViewController<LoginView> {
    let fetcher: AuthenticationFetching
    let coordinator: AuthenticationCoordinating

    override var navigationBarStyle: NavigationBarStyle {
        return .transparent
    }

    init(fetcher: AuthenticationFetching, coordinator: AuthenticationCoordinating) {
        self.fetcher = fetcher
        self.coordinator = coordinator
        super.init(baseCoordinator: coordinator)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Application doesn't use storyboard, init(coder:) shouldn't be called")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        prepareActions()
        prepareDelegates()
    }

    private func handleError(_ error: RequestError) {
        // TODO Handle firebase login register errors
        coordinator.onError(error)
    }
}

// MARK: - View preparation and button actions
extension LoginViewController {

    private func prepareView() {
        rootView.emailTextField.setTag(0)
        rootView.passwordTextField.setTag(1)
    }

    private func prepareActions() {
        rootView.loginButton.addTarget(self,
                                       action: #selector(onClickLoginButton),
                                       for: .touchUpInside)
    }

    private func prepareDelegates() {
        rootView.emailTextField.delegate = self
        rootView.passwordTextField.delegate = self
    }

    @objc func onClickLoginButton() {
        guard validateFields() else { return }
        fetcher.login(email: rootView.emailTextField.value,
                      password: rootView.passwordTextField.value)
            .done({ [weak self] _ in
                self?.coordinator.onLoginCompleted(fromRegister: false)
            }).catch({ [weak self] error in
                if let error = error as? RequestError {
                    if case .authError(let authError) = error {
                        self?.rootView.setErrorText(authError.message)
                    } else {
                        self?.handleError(error)
                    }
                }
            })
    }
}

private extension LoginViewController {
    
    private func validateFields() -> Bool {
        var errorTexts: [String] = []
        let email = rootView.emailTextField.value
        let password = rootView.passwordTextField.value

        if let error = AuthenticationValidator.validateEmail(email) {
            rootView.setError(to: rootView.emailTextField)
            errorTexts.append(error.errorText)
        }
        
        if let error = AuthenticationValidator.validatePassword(password) {
            rootView.setError(to: rootView.passwordTextField)
            errorTexts.append(error.errorText)
        }

        if errorTexts.count > 0 {
            rootView.setErrorText(errorTexts[0])
            return false
        }

        return true
    }
}

// MARK: - Text Field Delegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        rootView.clearErrors()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case rootView.emailTextField.tag:
            rootView.emailTextField.resignFirstResponder()
            rootView.passwordTextField.becomeFirstResponder()
        case rootView.passwordTextField.tag:
            rootView.passwordTextField.resignFirstResponder()
        default:
            rootView.emailTextField.resignFirstResponder()
            rootView.passwordTextField.resignFirstResponder()
        }
        return true
    }
}
