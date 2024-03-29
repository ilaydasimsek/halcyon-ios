import XCTest
import Mocker
import SwiftyJSON
import Alamofire
@testable import Halcyon

class AlamofireNetworkTests: XCTestCase {
    lazy var sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self] + (configuration.protocolClasses ?? [])
        return Session(configuration: configuration)
    }()
    
    var networking: Networking!
    
    override func setUp() {
        super.setUp()
        self.networking =  AlamofireNetwork(sessionManager: sessionManager)
    }
    
    func test_GetRequest_Success() {
        testRequestWithoutBody(with: MockService.getRequest, fail: false)
    }
    
    func test_GetRequest_Fail() {
        testRequestWithoutBody(with: MockService.getRequest, fail: true)
    }
    
    func test_PostRequest_Success() {
        self.testRequestWithBody(with: MockService.postRequest, fail: false)
    }
    
    func test_PostRequest_Fail() {
        self.testRequestWithBody(with: MockService.postRequest, fail: true)
    }
    
    func test_DeleteRequest_Success() {
        self.testRequestWithoutBody(with: MockService.deleteRequest, fail: false)
    }
    
    func test_DeleteRequest_Fail() {
        self.testRequestWithoutBody(with: MockService.deleteRequest, fail: true)
    }
    
    func test_PutRequest_Success() {
        self.testRequestWithBody(with: MockService.putRequest, fail: false)
    }
    
    func test_PutRequest_Fail() {
        self.testRequestWithBody(with: MockService.putRequest, fail: true)
    }
    
    func test_PatchRequest_Success() {
        self.testRequestWithBody(with: MockService.patchRequest, fail: false)
    }
    
    func test_PatchRequest_Fail() {
        self.testRequestWithBody(with: MockService.patchRequest, fail: true)
    }
}

// MARK: - Util functions
extension AlamofireNetworkTests {

    func testRequestWithoutBody(with request: Requestable, fail: Bool) {
        registerMock(with: request, fail: fail)
        if (fail) {
            self.testRequestFail(with: request)
        } else {
            self.testRequestSuccess(with: request)
        }
    }
    
    func testRequestWithBody(with request: Requestable, fail: Bool) {
        let requestBodyExpectation = expectation(description: "The request body should be correct")
        let onRequest: Mock.OnRequest = { urlRequest, bodyArguments in
            guard let bodyArguments = bodyArguments as? RequestParameters else {
                XCTFail("Body arguments must be of type RequestParameters")
                return
            }
            XCTAssertEqual(bodyArguments, request.parameters)

            requestBodyExpectation.fulfill()
        }
        registerMock(with: request, fail: fail, onRequest: onRequest)
        if (!fail) {
            self.testRequestSuccess(with: request)
        } else {
            self.testRequestFail(with: request)
        }
        wait(for: [requestBodyExpectation], timeout: 3.0)
    }

    func testRequestSuccess(with request: Requestable) {
        let requestExpectation = expectation(description: "Request should finish and return correct response")
        
        networking.request(request).done({ response in
            XCTAssertNoThrow(try JSON(data: response))
            
            let responseJson = try JSON(data: response)
            XCTAssertTrue(responseJson == Self.sampleJson)
            
            requestExpectation.fulfill()
        }).catch({ error in
            XCTFail(error.localizedDescription)
        })
        
        wait(for: [requestExpectation], timeout: 3.0)
    }

    func testRequestFail(with request: Requestable) {
        let requestExpectation = expectation(description: "Request should fail")
        
        networking.request(request).done({ response in
            XCTFail("Request should have failed")
        }).catch({ error in
            requestExpectation.fulfill()
        })
        
        wait(for: [requestExpectation], timeout: 3.0)
    }

    private func registerMock(with request: Requestable, fail: Bool, onRequest: Mock.OnRequest? = nil) {
        let mockedSampleData = try! JSONEncoder().encode(Self.sampleJson)
        let url: URL = request.baseUrl.appendingPathComponent(request.path)

        var mock = Mock(url: url,
                        dataType: .json,
                        statusCode: fail ? 500 : 200,
                        data: [getRequestEquivalent(for: request.method): mockedSampleData],
                        requestError: fail ? MockError.mock : nil
                        )
        mock.onRequest = onRequest
        mock.register()
    }
    
    private func getRequestEquivalent(for method: HttpMethod) -> Mock.HTTPMethod {
        switch method {
        case .get:
            return Mock.HTTPMethod.get
        case .post:
            return Mock.HTTPMethod.post
        case .put:
            return Mock.HTTPMethod.put
        case .patch:
            return Mock.HTTPMethod.patch
        case .delete:
            return Mock.HTTPMethod.delete
        }
    }
}


// MARK: - Mock Data
extension AlamofireNetworkTests {
    private static var sampleJson: JSON { return JSON(["test": "Main Screen",])}
}
