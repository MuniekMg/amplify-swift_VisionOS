//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public class AmplifyOperationTaskAdapter<Request: AmplifyOperationRequest, Success, Failure: AmplifyError>: AmplifyTask {
    let operation: AmplifyOperation<Request, Success, Failure>
    let childTask: ChildTask<Void, Success, Failure>
    var resultToken: UnsubscribeToken? = nil

    public init(operation: AmplifyOperation<Request, Success, Failure>) {
        self.operation = operation
        self.childTask = ChildTask(parent: operation)
        resultToken = operation.subscribe(resultListener: resultListener)
    }

    deinit {
        if let resultToken = resultToken {
            Amplify.Hub.removeListener(resultToken)
        }
    }

    public var result: Success {
        get async throws {
            try await childTask.result
        }
    }

    public func pause() async {
        operation.pause()
    }

    public func resume() async {
        operation.resume()
    }

    public func cancel() async {
        await childTask.cancel()
    }

    private func resultListener(_ result: Result<Success, Failure>) {
        Task {
            await childTask.finish(result)
        }
    }
}

public class AmplifyInProcessReportingOperationTaskAdapter<Request: AmplifyOperationRequest, InProcess, Success, Failure: AmplifyError>: AmplifyTask, AmplifyInProcessReportingTask {
    let operation: AmplifyInProcessReportingOperation<Request, InProcess, Success, Failure>
    let childTask: ChildTask<InProcess, Success, Failure>
    var resultToken: UnsubscribeToken? = nil
    var inProcessToken: UnsubscribeToken? = nil

    public init(operation: AmplifyInProcessReportingOperation<Request, InProcess, Success, Failure>) {
        self.operation = operation
        self.childTask = ChildTask(parent: operation)
        resultToken = operation.subscribe(resultListener: resultListener)
        inProcessToken = operation.subscribe(inProcessListener: inProcessListener)
    }

    deinit {
        if let resultToken = resultToken {
            Amplify.Hub.removeListener(resultToken)
        }
        if let inProcessToken = inProcessToken {
            Amplify.Hub.removeListener(inProcessToken)
        }
    }

    public var result: Success {
        get async throws {
            try await childTask.result
        }
    }

    public var progress: AsyncChannel<InProcess> {
        get async {
            await childTask.inProcess
        }
    }

    public func pause() async {
        operation.pause()
    }

    public func resume() async {
        operation.resume()
    }

    public func cancel() async {
        await childTask.cancel()
    }

    private func resultListener(_ result: Result<Success, Failure>) {
        Task {
            await childTask.finish(result)
        }
    }

    private func inProcessListener(_ inProcess: InProcess) {
        Task {
            try await childTask.report(inProcess)
        }
    }
}
