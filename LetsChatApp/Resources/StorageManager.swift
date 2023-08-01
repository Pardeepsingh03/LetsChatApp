//
//  StorageManager.swift
//  LetsChatApp
//
//  Created by MBA-0019 on 31/07/23.
//

import Foundation
import FirebaseStorage

class StorageManager{
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    func uplaodImage(with data: Data,fileName: String, completion: @escaping (Result<String,Error>) -> Void){
        storage.child("images/\(fileName)").putData(data,metadata: nil) { metaData, error in
            guard error == nil else {
                print("Failed to upload the image.")
                completion(.failure(errorMessages.failedToUpload))
                return
            }
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to download the image.")
                    completion(.failure(errorMessages.failedToDownload))
                    return
                }
                let urlString = url.absoluteString
                print("Downloaded URL string: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    func downloadImage(for path: String,completion: @escaping (Result<URL,Error>)-> Void){
      let reference = storage.child(path)
        reference.downloadURL { Url, error in
            guard let url = Url,error == nil else {
                completion(.failure(errorMessages.failedToDownload))
                return
            }
            completion(.success(url))
            
        }
    }
}

public enum errorMessages: Error{
    case failedToUpload
    case failedToDownload
    
}
