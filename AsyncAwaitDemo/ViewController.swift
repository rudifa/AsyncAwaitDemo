//
//  ViewController.swift
//  AsyncAwaitDemo
//
//  Created by Rudolf Farkas on 18.12.22.
//

/*
// TWO COMPILATION ERRORS

 import UIKit
 import Combine

 class MyViewController: UIViewController {
  // UIImageView that will display the image
  @IBOutlet weak var imageView: UIImageView!

  // Create a MainActor
  let mainActor = MainActor()

  // Create a Task that makes a network request to retrieve the image data
  let imageTask = Task {
    let url = URL(string: "https://example.com/image.jpg")!
    let data = try Data(contentsOf: url)
    return UIImage(data: data)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Execute the imageTask on the main thread and update the imageView with the retrieved image
    mainActor.execute(imageTask) { result in
      switch result {
      case .success(let image):
        self.imageView.image = image
      case .failure(let error):
        print("Error fetching image: \(error)")
      }
    }
  }
 }

 */

// In a UIViewController, I want to fetch an image form a public website, asynchronously, and display it in a UIImageView


/*

// THIS WORKS

 import UIKit

 class ViewController: UIViewController {

     @IBOutlet weak var imageView: UIImageView!

     override func viewDidLoad() {
         super.viewDidLoad()

         // URL of the image to fetch
         let imageURL = URL(string: "https://picsum.photos/200")!

         // Create a session to make the network request
         let session = URLSession.shared

         // Create a task to make the request
         let task = session.dataTask(with: imageURL) { (data, response, error) in
             // Check for errors
             if let error = error {
                 print("Error fetching image: \(error)")
                 return
             }

             // Check for successful response
             guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                 print("Error: Invalid response")
                 return
             }

             // Check for data
             guard let data = data else {
                 print("Error: No data returned")
                 return
             }

             // Create an image object from the data
             let image = UIImage(data: data)

             // Update the image view on the main thread
             DispatchQueue.main.async {
                 self.imageView.image = image
             }
         }

         // Start the task
         task.resume()
     }
 }
*/

/*

// THIS COMPILES BUT PRODUCES NO PICTURE AND NO DIAGNOSTICS

 import UIKit
 import Combine

 class ViewController: UIViewController {

     @IBOutlet weak var imageView: UIImageView!

     override func viewDidLoad() {
         super.viewDidLoad()

         // URL of the image to fetch
         let imageURL = URL(string: "https://picsum.photos/200")!

         // Create a publisher to make the network request
         let imagePublisher = URLSession.shared.dataTaskPublisher(for: imageURL)
             .map { UIImage(data: $0.data) }
             .replaceError(with: nil)
             .eraseToAnyPublisher()

         // Subscribe to the publisher
         let cancellable = imagePublisher
             .receive(on: DispatchQueue.main)
             .sink { [weak self] image in
                 print("image.size= \(String(describing: image?.size))")
                 self?.imageView.image = image
             }
     }
 }
*/

/*
// THIS COMPILES BUT PRODUCES NO PICTURE AND NO DIAGNOSTICS
// except the 2 outermost prints

import Combine
import UIKit

class ViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // URL of the image to fetch
        let imageURL = URL(string: "https://picsum.photos/200")!

        // Create a publisher to make the network request
        let imagePublisher = URLSession.shared.dataTaskPublisher(for: imageURL)
            .map { data, response -> (UIImage?, URLResponse?) in
                print("Received data and response:")
                print(data)
                print(response)
                return (UIImage(data: data), response)
            }
            .replaceError(with: (nil, nil))
            .eraseToAnyPublisher()

        print("imagePublisher= \(imagePublisher)")

        // Subscribe to the publisher
        let cancellable = imagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image, response in
                print("Received image and response:")
                print(image as Any)
                print(response as Any)
                self?.imageView.image = image
            }
        print("cancellable= \(cancellable.hashValue)")
    }
}
*/

/*
// THIS WORKS

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // URL of the image to fetch
        let imageURL = URL(string: "https://picsum.photos/200")!

        // Asynchronously fetch the image
        asyncFetchImage(imageURL: imageURL) { result in
            switch result {
            case .success(let image):
                // Update the image view on the main thread
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            case .failure(let error):
                print("Error fetching image: \(error)")
            }
        }
    }

    // Asynchronously fetches an image from the specified URL
    func asyncFetchImage(imageURL: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        // Create a session to make the network request
        let session = URLSession.shared

        // Create a data task to make the request
        let task = session.dataTask(with: imageURL) { (data, response, error) in
            if let error = error {
                // Return the error if there was one
                completion(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                // Return an error if the response is invalid
                completion(.failure(FetchError.invalidResponse))
                return
            }

            guard let data = data else {
                // Return an error if there is no data
                completion(.failure(FetchError.noData))
                return
            }

            // Create an image object from the data
            guard let image = UIImage(data: data) else {
                // Return an error if the image could not be created
                completion(.failure(FetchError.invalidImage))
                return
            }

            // Return the image
            completion(.success(image))
        }

        // Start the task
        task.resume()
    }
}

// Custom error type for image fetching
enum FetchError: Error {
    case invalidResponse
    case noData
    case invalidImage
}
*/

/*

// TWO COMPILATION ERRORS

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // URL of the image to fetch
        let imageURL = URL(string: "https://picsum.photos/200")!

        // Asynchronously fetch the image
        do {
            let image = try asyncFetchImage(imageURL: imageURL)
            // Update the image view on the main thread
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        } catch {
            print("Error fetching image: \(error)")
        }
    }

    // Asynchronously fetches an image from the specified URL
    func asyncFetchImage(imageURL: URL) throws -> UIImage {
        // Create a session to make the network request
        let session = URLSession.shared

        // Create a data task to make the request
        let task = session.dataTask(with: imageURL) { (data, response, error) in
            if let error = error {
                // Throw the error if there was one
                throw error
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                // Throw an error if the response is invalid
                throw FetchError.invalidResponse
            }

            guard let data = data else {
                // Throw an error if there is no data
                throw FetchError.noData
            }

            // Create an image object from the data
            guard let image = UIImage(data: data) else {
                // Throw an error if the image could not be created
                throw FetchError.invalidImage
            }

            // Return the image
            return image
        }

        // Start the task
        task.resume()

        // Wait for the task to complete
        task.waitUntilFinished()

        // Return the result of the task
        return task.result!
    }
}

// Custom error type for image fetching
enum FetchError: Error {
    case invalidResponse
    case noData
    case invalidImage
}

*/


/*

// TWO COMPILATION ERRORS

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // URL of the image to fetch
        let imageURL = URL(string: "https://picsum.photos/200")!

        // Asynchronously fetch the image
        do {
            let image = try asyncFetchImage(imageURL: imageURL)
            // Update the image view on the main thread
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        } catch {
            print("Error fetching image: \(error)")
        }
    }

    // Asynchronously fetches an image from the specified URL
    func asyncFetchImage(imageURL: URL) throws -> UIImage {
        // Create a session to make the network request
        let session = URLSession.shared

        // Create a data task to make the request
        let task = session.dataTask(with: imageURL) { (data, response, error) in
            if let error = error {
                // Throw the error if there was one
                throw error
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                // Throw an error if the response is invalid
                throw FetchError.invalidResponse
            }

            guard let data = data else {
                // Throw an error if there is no data
                throw FetchError.noData
            }

            // Create an image object from the data
            guard let image = UIImage(data: data) else {
                // Throw an error if the image could not be created
                throw FetchError.invalidImage
            }

            // Return the image
            return image
        }

        // Start the task
        task.resume()

        // Wait for the task to complete
        task.waitUntilFinished()

        // Return the result of the task
        return task.result!
    }
}

// Custom error type for image fetching
enum FetchError: Error {
    case invalidResponse
    case noData
    case invalidImage
}

*/

/*

// CHATBOT DID NOT FINISH THE RESPONSE

 import UIKit

 class ViewController: UIViewController {

     @IBOutlet weak var imageView: UIImageView!

     override func viewDidLoad() {
         super.viewDidLoad()

         // URL of the image to fetch
         let imageURL = URL(string: "https://picsum.photos/200")!

         // Asynchronously fetch the image
         do {
             let image = try asyncFetchImage(imageURL: imageURL)
             // Update the image view on the main thread
             DispatchQueue.main.async {
                 self.imageView.image = image
             }
         } catch {
             print("Error fetching image: \(error)")
         }
     }

     // Asynchronously fetches an image from the specified URL
     func asyncFetchImage(imageURL: URL) throws -> UIImage {
         // Create a session to make the network request
         let session = URLSession.shared

         // Create a semaphore to wait for the task to complete
         let semaphore = DispatchSemaphore(value: 0)

         // Create a data task to make the request
         let task = session.dataTask(with: imageURL) { (data, response, error) in
             if let error = error {
                 // Throw the error if there was one
                 throw error
             }

             guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                 // Throw an error if the response is invalid
                 throw FetchError.in

// chatGPT stopped here...
 */

/*

// TWO COMPILATION ERRORS

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // URL of the image to fetch
        let imageURL = URL(string: "https://picsum.photos/200")!

        // Asynchronously fetch the image
        do {
            let image = try asyncFetchImage(imageURL: imageURL)
            // Update the image view on the main thread
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        } catch {
            print("Error fetching image: \(error)")
        }
    }

    // Asynchronously fetches an image from the specified URL
    func asyncFetchImage(imageURL: URL) throws -> UIImage {
        // Create a session to make the network request
        let session = URLSession.shared

        // Create a semaphore to wait for the task to complete
        let semaphore = DispatchSemaphore(value: 0)

        // Create a data task to make the request
        let task = session.dataTask(with: imageURL) { (data, response, error) in
            if let error = error {
                // Throw the error if there was one
                throw error
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                // Throw an error if the response is invalid
                throw FetchError.invalidResponse
            }

            guard let data = data else {
                // Throw an error if there is no data
                throw FetchError.noData
            }

            // Create an image object from the data
            guard let image = UIImage(data: data) else {
                // Throw an error if the image could not be created
                throw FetchError.invalidImage
            }

            // Signal the semaphore to indicate that the task is complete
            semaphore.signal()

            // Return the image
            return image
        }

        // Start the task
        task.resume()

        // Wait for the task to complete
        semaphore.wait()

        // Return the result of the task
        return task.result!
    }
}

// Custom error type for image fetching
enum FetchError: Error {
    case invalidResponse
    case noData
    case invalidImage
}
*/


/*

// TWO COMPILATION ERRORS

 import UIKit

 class ViewController: UIViewController {

     @IBOutlet weak var imageView: UIImageView!

     override func viewDidLoad() {
         super.viewDidLoad()

         // URL of the image to fetch
         let imageURL = URL(string: "https://picsum.photos/200")!

         // Asynchronously fetch the image
         do {
             let image = try asyncFetchImage(imageURL: imageURL)
             // Update the image view on the main thread
             DispatchQueue.main.async {
                 self.imageView.image = image
             }
         } catch {
             print("Error fetching image: \(error)")
         }
     }

     // Asynchronously fetches an image from the specified URL
     func asyncFetchImage(imageURL: URL) throws -> UIImage {
         // Create a session to make the network request
         let session = URLSession.shared

         // Create a semaphore to wait for the task to complete
         let semaphore = DispatchSemaphore(value: 0)

         // Create a data task to make the request
         let task = session.dataTask(with: imageURL) { (data, response, error) in
             if let error = error {
                 // Throw the error if there was one
                 throw error
             }

             guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                 // Throw an error if the response is invalid
                 throw FetchError.invalidResponse
             }

             guard let data = data else {
                 // Throw an error if there is no data
                 throw FetchError.noData
             }

             // Create an image object from the data
             guard let image = UIImage(data: data) else {
                 // Throw an error if the image could not be created
                 throw FetchError.invalidImage
             }

             // Signal the semaphore to indicate that the task is complete
             semaphore.signal()

             // Set the result of the task to the image
             task.setResult(image)
         }

         // Start the task
         task.resume()

         // Wait for the task to complete
         semaphore.wait()

         // Return the result of the task
         return task.result!
     }
 }

 // Custom error type for image fetching
 enum FetchError: Error {
     case invalidResponse
     case noData
     case invalidImage
 }
*/



/*
// THIS WORKS

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // URL of the image to fetch
        let imageURL = URL(string: "https://picsum.photos/200")!

        // Create a URL request for the image
        let request = URLRequest(url: imageURL)

        // Create a session to make the request
        let session = URLSession(configuration: .default)

        // Create a data task to make the request
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                // Handle the error
                print("Error fetching image: \(error)")
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                // Handle the error
                print("Error: invalid response")
                return
            }

            guard let data = data else {
                // Handle the error
                print("Error: no data")
                return
            }

            // Create an image object from the data
            guard let image = UIImage(data: data) else {
                // Handle the error
                print("Error: invalid image")
                return
            }

            // Update the image view on the main thread
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }

        // Start the task
        task.resume()
    }
}

*/

// THIS WORKS

//oops, your code is unfinished
//
//I apologize for the error. Here is the corrected version of the code that adds a button to your view controller to asynchronously fetch a new image and display it in a UIImageView:
//
//Copy code

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var fetchButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the action for the fetch button
        fetchButton.addTarget(self, action: #selector(fetchImage), for: .touchUpInside)
    }

    // Action for the fetch button
    @objc func fetchImage() {
        // URL of the image to fetch
        let imageURL = URL(string: "https://picsum.photos/200")!

        // Create a URL request for the image
        let request = URLRequest(url: imageURL)

        // Create a session to make the request
        let session = URLSession(configuration: .default)

        // Create a data task to make the request
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                // Handle the error
                print("Error fetching image: \(error)")
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                // Handle the error
                print("Error: invalid response")
                return
            }

            guard let data = data else {
                // Handle the error
                print("Error: no data")
                return
            }

            // Create an image object from the data
            guard let image = UIImage(data: data) else {
                // Handle the error
                print("Error: invalid image")
                return
            }

            // Update the image view on the main thread
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }

        // Start the task
        task.resume()
    }
}


//This code sets the action of the fetchButton to the fetchImage function, which creates a data task to make a request to the specified image URL. When the request is complete, the data task's completion handler is called, and it handles any errors that may have occurred and creates an image object from the data if the request was successful
//
//Rudi Farkas
//
//This works, splendid (of course, I had to add the storyboard button myself and wire it to your button outlet)
//
//I'm glad to hear that the code is working for you! Let me know if you have any other questions or if there is anything else I can do to assist you.
//
