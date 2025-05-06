//
//  Cell.swift
//  MLTimer
//
//  Created by Maryna Bereza on 05.05.2025.
//

import Foundation
import UIKit

class Cell<T: UIView>: UICollectionViewCell {
    
    let rootView = T()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(rootView)
        rootView.translatesAutoresizingMaskIntoConstraints = false
        rootView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        rootView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        rootView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        rootView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}

extension Cell: Reusable {}


protocol Reusable {
    static var reuseId: String { get }
}

extension Reusable {
    static var reuseId: String { .init(describing: self) }
}

extension Cell {
    
    static func register(in collectionView: UICollectionView) {
        collectionView.register(Self.self, forCellWithReuseIdentifier: Self.reuseId)
    }
    
    static func dequeue(from collectionView: UICollectionView, for indexPath: IndexPath) -> Self {
        collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! Self
    }
}

