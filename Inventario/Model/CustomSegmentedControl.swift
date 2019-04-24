//
//  CustomSegmentedControl.swift
//  CustomSegmentControl
//
//  Created by Luis Isaac Maya on 3/1/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit

@IBDesignable
class CustomSegmentedControl: UIControl {
    var buttons = [UIButton]()
    var selector : UIView!
    var selectedSegmentIndex = 0
    
    @IBInspectable
    var borderWidth : CGFloat = 0 {
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    
    
    @IBInspectable
    var borderColor : UIColor = UIColor.clear{
        didSet{
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    var commaSeparatedButtonTitles : String = "" {
        didSet{
            updateView()
        }
    }
    
    @IBInspectable
    var textColor : UIColor = .gray{
        didSet{
            updateView()
        }
    }
    
    @IBInspectable
    var selectorColor : UIColor = .darkGray{
        didSet{
            updateView()
        }
    }
    
    @IBInspectable
    var selectorTextColor : UIColor = .green{
        didSet{
            updateView()
        }
    }
    

    
    func updateView()  {
        buttons.removeAll()
        subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        let buttonTitles = commaSeparatedButtonTitles.components(separatedBy: ",")
        
        for buttonTitle in buttonTitles{
            let button = UIButton(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            buttons.append(button)
        }
        
        addSelector(buttonTitles: buttonTitles)
        
        //MARK: SE CREA UN STACKVIEW PARA ALMACENAR LOS BOTONES
        let sv = UIStackView(arrangedSubviews: buttons)
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillProportionally
        addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        sv.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        sv.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        sv.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    
    func addSelector(buttonTitles : [String])  {
        buttons[0].setTitleColor(selectorTextColor, for: .normal)
        
        let selectorWidth = frame.width /  CGFloat(buttonTitles.count)
        selector = UIView(frame: CGRect(x: 0, y: 0, width: selectorWidth, height: frame.height))
        
        //MARK: ESTA LINEA SE PUEDE COMENTAR SI NO SE NECESITA REDONDEAR LAS ESQUINAS
        selector.layer.cornerRadius = frame.height / 2
        
        //MARK: ESTA LINEA SE PUEDE DESCOMENTAR SI SE QUIERE CAMBIAR EL MODO DE SEÑALAR UNA OPCION
        //selector.backgroundColor = selectorColor
        
        //MARK: SE CREA UN BORDE EN LA PARTE DE ABAJO DEL BOTON PARA POSTERIOMENTE SEÑALARLO
        let border = CALayer()
        
        //MARK: ESTA LINEA SE PUEDE COMENTAR SI SE QUIERE CAMBIAR EL MODO DE SEÑALAR UNA OPCION
        border.backgroundColor = selectorTextColor.cgColor
        
        border.frame = CGRect(x: selector.frame.minX, y: selector.frame.maxY, width: selector.frame.width, height: 3.0)
        selector.layer.addSublayer(border)
        
        addSubview(selector)
        
    }
    
    
    override func draw(_ rect: CGRect) {
        //MARK: ESTA LINEA SE PUEDE COMENTAR SI NO SE NECESITA REDONDEAR LAS ESQUINAS
        layer.cornerRadius = frame.height / 2
    }
    
    @objc func buttonTapped(button: UIButton)  {
        for (buttonIndex,btn) in buttons.enumerated(){
            btn.setTitleColor(textColor, for: .normal)
            
            if btn == button{
                selectedSegmentIndex = buttonIndex
                let selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(buttonIndex)
                UIView.animate(withDuration: 0.3) {
                    self.selector.frame.origin.x = selectorStartPosition
                }
                
                
                btn.setTitleColor(selectorTextColor, for: .normal)
            }
        }
        sendActions(for: .valueChanged)
    }
    
    
    

}
