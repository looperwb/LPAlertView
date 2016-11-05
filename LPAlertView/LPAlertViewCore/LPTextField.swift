//
//  LPTextField.swift
//  AlertView
//
//  Created by zwb on 2016/11/4.
//  Copyright © 2016年 zwb. All rights reserved.
//

import UIKit

public class LPTextField: UITextField {

    public typealias BtnAction = () -> Void
    public typealias SingleDoneAction = (textField: UITextField, selectedIndex: Int, selectedValue: String) -> Void
    public typealias MultipleDoneAction = (textField: UITextField, selectedIndexs: [Int], selectedValues: [String]) -> Void
    public typealias DateDoneAction = (textField: UITextField, selectedDate: NSDate) -> Void
    public typealias MultipleAssociatedDataType = [[[String: [String]?]]]
    
    ///  保存pickerView的初始化
    private var setUpPickerClosure: (() -> LPPickerView)?
    ///  如果设置了autoSetSelectedText为true 将自动设置text的值, 默认以空格分开多列选择, 但你仍然可以在响应完成的closure中修改text的值
    private var autoSetSelectedText = false
    
    //MARK: 初始化
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
    }
    
    // 从xib或storyboard中初始化时候调用
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

// MARK: - 监听通知
extension LPTextField {
    
    private func setup() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LPTextField.didBeginEdit), name: UITextFieldTextDidBeginEditingNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LPTextField.didEndEdit), name: UITextFieldTextDidEndEditingNotification, object: self)
    }
    
    // 开始编辑添加pickerView
    func didBeginEdit() {
        let pickerView = setUpPickerClosure?()
        pickerView?.delegate = self
        inputView = pickerView
    }
    
    // 编辑完成销毁pickerView
    func didEndEdit() {
        inputView = nil
    }
    
    override public func caretRectForPosition(position: UITextPosition) -> CGRect {
        return CGRectZero
    }
    
}

// MARK: - 使用方法
extension LPTextField {
    
    /// 单列选择器
    ///
    ///  - parameter title:                      标题
    ///  - parameter data:                       数据
    ///  - parameter defaultSeletedIndex:        默认选中的行数
    ///  - parameter autoSetSelectedText:        设置为true的时候, 将按默认的格式自动设置textField的值
    ///  - parameter doneAction:                 响应完成的Closure
    ///
    public func showSingleColPicker(toolBarTitle: String,
                                            data: [String],
                            defaultSelectedIndex: Int?,
                             autoSetSelectedText: Bool,
                                      doneAction: SingleDoneAction?) {
        
        self.autoSetSelectedText = autoSetSelectedText

        // 保存在这个closure中, 在开始编辑的时候在执行, 避免像之前在这里直接初始化pickerView, 每个SelectionTextField在调用这个方法的时候就初始化pickerView,当有多个pickerView的时候就很消耗内存
        setUpPickerClosure = { () -> LPPickerView in
            
            return LPPickerView.singleColPicker(toolBarTitle, singleColData: data, defaultIndex: defaultSelectedIndex, cancelAction: { [unowned self] in
                
                    self.endEditing(true)
                
                }, doneAction: { [unowned self] (selectedIndex: Int, selectedValue: String) -> Void in
                   
                    doneAction?(textField: self, selectedIndex: selectedIndex, selectedValue: selectedValue)
                    self.endEditing(true)
                })
        }
    }
    
    /// 多列不关联选择器
    ///
    ///  - parameter title:                      标题
    ///  - parameter data:                       数据
    ///  - parameter defaultSeletedIndexs:       默认选中的每一列的行数
    ///  - parameter autoSetSelectedText:        设置为true的时候, 将俺默认的格式自动设置textField的值
    ///  - parameter doneAction:                 响应完成的Closure
    ///
    public func showMultipleColsPicker(toolBarTitle: String,
                                               data: [[String]],
                              defaultSelectedIndexs: [Int]?,
                                autoSetSelectedText: Bool,
                                         doneAction: MultipleDoneAction?) {
        
        self.autoSetSelectedText = autoSetSelectedText

        setUpPickerClosure = { () -> LPPickerView in

            return LPPickerView.multipleCosPicker(toolBarTitle,
                                                  multipleColsData: data,
                                                  defaultSelectedIndexs: defaultSelectedIndexs,
                                                  cancelAction: { [unowned self] in
                    self.endEditing(true)
                
                }, doneAction:{ [unowned self] (selectedIndexs: [Int], selectedValues: [String]) -> Void in
                    
                    doneAction?(textField:self, selectedIndexs: selectedIndexs, selectedValues: selectedValues)
                    self.endEditing(true)
                })
        }
    }
    
    /// 多列关联选择器
    ///
    ///  - parameter title:                      标题
    ///  - parameter data:                       数据, 数据的格式参照示例
    ///  - parameter defaultSeletedIndexs:       默认选中的每一列的行数
    ///  - parameter autoSetSelectedText:        设置为true的时候, 将按默认的格式自动设置textField的值
    ///  - parameter doneAction:                 响应完成的Closure
    ///
    public func showMultipleAssociatedColsPicker(toolBarTitle: String,
                                                 data: MultipleAssociatedDataType,
                                                 defaultSelectedValues: [String]?,
                                                 autoSetSelectedText: Bool,
                                                 doneAction: MultipleDoneAction?) {
        
        self.autoSetSelectedText = autoSetSelectedText

        setUpPickerClosure = { () -> LPPickerView in
        
            return LPPickerView.multipleAssociatedCosPicker(toolBarTitle,
                                                            multipleAssociatedColsData: data,
                                                            defaultSelectedValues: defaultSelectedValues,
                                                            cancelAction: { [unowned self] in
                
                    self.endEditing(true)
                
                }, doneAction:{[unowned self] (selectedIndexs: [Int], selectedValues: [String]) -> Void in
                
                    doneAction?(textField:self, selectedIndexs: selectedIndexs, selectedValues: selectedValues)
                    self.endEditing(true)
                })
        }

    }

    
    /// 城市选择器
    ///
    ///  - parameter title:                      标题
    ///  - parameter defaultSeletedValues:       默认选中的每一列的值, 注意不是行数
    ///  - parameter autoSetSelectedText:        设置为true的时候, 将按默认的格式自动设置textField的值
    ///  - parameter doneAction:                 响应完成的Closure
    ///
    public func showCitiesPicker(toolBarTitle: String, defaultSelectedValues: [String]?,autoSetSelectedText: Bool, doneAction: MultipleDoneAction?) {
        self.autoSetSelectedText = autoSetSelectedText

        setUpPickerClosure = { () -> LPPickerView in
            
            return LPPickerView.citiesPicker(toolBarTitle,
                                             defaultSelectedValues: defaultSelectedValues,
                                             cancelAction: { [unowned self] in
                    self.endEditing(true)
                
                }, doneAction:{[unowned self] (selectedIndexs: [Int], selectedValues: [String]) -> Void in
                    
                    doneAction?(textField:self,selectedIndexs: selectedIndexs, selectedValues: selectedValues)
                    self.endEditing(true)
                })
        }
    
    }
    
    /// 日期选择器
    ///
    ///  - parameter title:                      标题
    ///  - parameter datePickerSetting:          可配置UIDatePicker的样式
    ///  - parameter autoSetSelectedText:        设置为true的时候, 将按默认的格式自动设置textField的值
    ///  - parameter doneAction:                 响应完成的Closure
    ///
    public func showDatePicker(toolBarTitle: String,
                               datePickerSetting: DatePickerSetting = DatePickerSetting(),
                               autoSetSelectedText: Bool,
                               doneAction: DateDoneAction?) {
        
        self.autoSetSelectedText = autoSetSelectedText

        setUpPickerClosure = { () -> LPPickerView in
            
           return LPPickerView.datePicker(toolBarTitle,
                                          datePickerSetting: datePickerSetting,
                                          cancelAction: { [unowned self] in
            
                    self.endEditing(true)
                
                }, doneAction: {[unowned self]  (selectedDate) in
                    
                    doneAction?(textField:self, selectedDate: selectedDate)
                    self.endEditing(true)
            })
        }
    }
}

// MARK: - PickerViewDelegate -- 如果设置了autoSetSelectedText为true 这些代理方法中将以默认的格式自动设置textField的值
extension LPTextField: PickerViewDelegate {
    public func singleColDidSelecte(selectedIndex: Int, selectedValue: String) {
        if autoSetSelectedText {
            text = " " + selectedValue
        }
    }
    
    public func multipleColsDidSelecte(selectedIndexs: [Int], selectedValues: [String]) {
        if autoSetSelectedText {
            text = selectedValues.reduce("", combine: { (result, selectedValue) -> String in
                 result + " " + selectedValue
            })
        }
    }
    
    public func dateDidSelecte(selectedDate: NSDate) {
        if autoSetSelectedText {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let string = formatter.stringFromDate(selectedDate)
            text = " " + string
        }
    }
}
