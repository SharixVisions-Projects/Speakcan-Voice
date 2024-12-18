import UIKit
import FSPagerView

class CustomPagerViewCell: FSPagerViewCell {
    let activityIndicator = UIActivityIndicatorView(style: .large)
  
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupActivityIndicator()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() {
        activityIndicator.layer.backgroundColor = UIColor.green.cgColor
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

