# Felloh iOS Payment SDK

[![Build & Test](https://github.com/felloh-org/ios-sdk/actions/workflows/build.yml/badge.svg)](https://github.com/felloh-org/ios-sdk/actions/workflows/build.yml)

Embed Felloh payment forms in your iOS app. Supports card payments and open banking.

## Requirements

- iOS 15.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/felloh-org/ios-sdk.git", from: "1.0.0")
]
```

Or in Xcode: **File > Add Package Dependencies** and enter the repository URL.

## Quick Start

### SwiftUI

```swift
import FellohPaymentSDK

struct CheckoutView: View {
    var body: some View {
        FellohPayment(
            configuration: FellohPaymentConfiguration(
                publicKey: "pk_live_YOUR_PUBLIC_KEY",
                environment: .sandbox
            ),
            ecommerceID: "550e8400-e29b-41d4-a716-446655440000",
            onSuccess: { transaction in
                print("Payment succeeded: \(transaction.id)")
            },
            onDecline: { transaction in
                print("Payment declined: \(transaction.id)")
            }
        )
        .frame(height: 500)
    }
}
```

### UIKit

```swift
import FellohPaymentSDK

class CheckoutViewController: UIViewController, FellohPaymentDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let config = FellohPaymentConfiguration(
            publicKey: "pk_live_YOUR_PUBLIC_KEY",
            environment: .sandbox
        )

        let paymentView = FellohPaymentView(configuration: config)
        paymentView.delegate = self
        paymentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(paymentView)

        NSLayoutConstraint.activate([
            paymentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            paymentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            paymentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            paymentView.heightAnchor.constraint(equalToConstant: 500)
        ])

        try? paymentView.render(ecommerceID: "550e8400-e29b-41d4-a716-446655440000")
    }

    func fellohPaymentDidRender(_ paymentView: FellohPaymentView) {
        print("Payment form loaded")
    }

    func fellohPayment(_ paymentView: FellohPaymentView, didSucceedWith transaction: FellohTransaction) {
        print("Payment succeeded: \(transaction.id)")
    }

    func fellohPayment(_ paymentView: FellohPaymentView, didDeclineWith transaction: FellohTransaction) {
        print("Payment declined: \(transaction.id)")
    }

    func fellohPayment(_ paymentView: FellohPaymentView, isProcessing transaction: FellohTransaction) {
        print("Payment processing: \(transaction.id)")
    }
}
```

## Configuration

### FellohPaymentConfiguration

| Parameter     | Type                 | Default       | Description                              |
|---------------|----------------------|---------------|------------------------------------------|
| `publicKey`   | `String`             | *required*    | Publishable key from Felloh Dashboard    |
| `environment` | `FellohEnvironment`  | `.production` | Payment environment                      |
| `moto`        | `Bool`               | `false`       | Mail Order/Telephone Order mode          |
| `design`      | `FellohDesignOptions`| see below     | UI options for the payment form          |

### FellohDesignOptions

| Parameter   | Type   | Default | Description                    |
|-------------|--------|---------|--------------------------------|
| `payButton` | `Bool` | `true`  | Show the built-in pay button   |
| `storeCard` | `Bool` | `true`  | Show the card storage option   |

### FellohEnvironment

| Case          | Description                          |
|---------------|--------------------------------------|
| `.production` | Live payments                        |
| `.sandbox`    | Testing with sandbox credentials     |
| `.staging`    | Internal staging environment         |
| `.dev`        | Local development (`localhost:3010`) |

## Custom Pay Button

Hide the built-in pay button and trigger payment from your own UI:

```swift
let config = FellohPaymentConfiguration(
    publicKey: "pk_live_YOUR_PUBLIC_KEY",
    design: FellohDesignOptions(payButton: false)
)

let paymentView = FellohPaymentView(configuration: config)
try paymentView.render(ecommerceID: "550e8400-e29b-41d4-a716-446655440000")

// Trigger from your own button
@IBAction func payTapped(_ sender: Any) {
    paymentView.pay()
}
```

## Events

### Delegate (UIKit)

Conform to `FellohPaymentDelegate`. All methods have default empty implementations.

| Method | Fires when |
|--------|-----------|
| `fellohPaymentDidRender(_:)` | Form finishes loading |
| `fellohPayment(_:didSucceedWith:)` | Payment completes successfully |
| `fellohPayment(_:didDeclineWith:)` | Payment is declined |
| `fellohPayment(_:isProcessing:)` | Payment is submitted and processing |

### Closures

Set closure properties directly on `FellohPaymentView`:

```swift
paymentView.onRender = { print("Rendered") }
paymentView.onSuccess = { tx in print("Success: \(tx.id)") }
paymentView.onDecline = { tx in print("Declined: \(tx.id)") }
paymentView.onProcessing = { tx in print("Processing: \(tx.id)") }
```

Both delegate and closure callbacks fire for each event.

## Status

Check the current payment form status:

```swift
let status = paymentView.status // .preload, .rendered, .processing, .success, .declined
```

## Obtaining an Ecommerce ID

The `ecommerceID` is created server-side using the Felloh API. See the [Felloh API documentation](https://docs.felloh.com) for details.

## License

MIT
