//
//  ToolBarView.swift
//  AlertView
//
//  Created by zwb on 2016/11/4.
//  Copyright © 2016年 zwb. All rights reserved.
//

import UIKit

// MARK:- PickerViewDelegate 用于自动设置TextField的选中值
public protocol PickerViewDelegate: class {
    func singleColDidSelecte(selectedIndex: Int, selectedValue: String)
    func multipleColsDidSelecte(selectedIndexs: [Int], selectedValues: [String])
    func dateDidSelecte(selectedDate: NSDate)
}

// MARK:- 配置UIDatePicker的样式
public struct DatePickerSetting {
    
    public var date = NSDate()
    public var dateMode = UIDatePickerMode.Date
    // 最小时间
    public var minimumDate: NSDate?
    // 最大时间
    public var maximumDate: NSDate?
    public init() {
        
    }
}

// MARK:- PickerView
public class LPPickerView: UIView {
    
    private let screenWidth = UIScreen.mainScreen().bounds.size.width
    private let pickerViewHeight = 216.0
    private let toolBarHeight = 44.0
    
    public enum PickerStyles {
        case Single
        case Multiple
        case MultipleAssociated
        case Date
    }
    
    public weak var delegate: PickerViewDelegate?
    private var toolBarTitle = "请选择" {
        didSet {
            toolBar.title = toolBarTitle
        }
    }
    
    private var pickerStyle: PickerStyles = .Single
    // 配置UIDatePicker的样式
    private var datePickerSetting = DatePickerSetting() {
        didSet {
            datePicker.date = datePickerSetting.date
            datePicker.minimumDate = datePickerSetting.minimumDate
            datePicker.maximumDate = datePickerSetting.maximumDate
            datePicker.datePickerMode = datePickerSetting.dateMode
            /// set currentDate
            selectedDate = datePickerSetting.date
        }
    }
    
    public typealias BtnAction = () -> Void
    public typealias SingleDoneAction = (selectedIndex: Int, selectedValue: String) -> Void
    public typealias MultipleDoneAction = (selectedIndexs: [Int], selectedValues: [String]) -> Void
    public typealias DateDoneAction = (selectedDate: NSDate) -> Void
    public typealias MultipleAssociatedDataType = [[[String: [String]?]]]

    private var cancelAction: BtnAction? = nil {
        didSet {
            toolBar.cancelAction = cancelAction
        }
    }
    
    // MARK:- 只有一列的时候用到的属性
    private var singleDoneOnClick: SingleDoneAction? = nil {
        didSet {
            toolBar.doneAction =  {[unowned self] in
                self.singleDoneOnClick?(selectedIndex: self.selectedIndex, selectedValue: self.selectedValue)
            }
        }
    }
    
    private var defalultSelectedIndex: Int? = nil {
        didSet {
            if let defaultIndex = defalultSelectedIndex, singleData = singleColData {
                // 判断下标是否合法
                assert(defaultIndex >= 0 && defaultIndex < singleData.count, "设置的默认选中Index不合法")
                
                if defaultIndex >= 0 && defaultIndex < singleData.count {
                    // 设置默认值
                    selectedIndex = defaultIndex
                    selectedValue = singleData[defaultIndex]
                    // 滚动到默认位置
                    pickerView.selectRow(defaultIndex, inComponent: 0, animated: false)
                    
                }
                
            } else { // 没有默认值设置0行为默认值
                selectedIndex = 0
                selectedValue = singleColData![0]
                pickerView.selectRow(0, inComponent: 0, animated: false)
                
            }
        }
    }
    
    private var singleColData: [String]? = nil
    private var selectedIndex: Int = 0
    private var selectedValue: String = "" {
        didSet {
            delegate?.singleColDidSelecte(selectedIndex, selectedValue: selectedValue)
        }
    }
    
    // MARK:- 有多列不关联的时候用到的属性
    private var multipleDoneOnClick: MultipleDoneAction? = nil {
        didSet {
            toolBar.doneAction =  {[unowned self] in
                self.multipleDoneOnClick?(selectedIndexs: self.selectedIndexs, selectedValues: self.selectedValues)
            }
        }
    }
    
    private var multipleColsData: [[String]]? = nil {
        didSet {
            if let multipleData = multipleColsData {
                for _ in multipleData.indices {
                    selectedIndexs.append(0)
                    selectedValues.append(" ")
                }
            }
        }
    }
    
    private var selectedIndexs: [Int] = []
    private var selectedValues: [String] = [] {
        didSet {
            delegate?.multipleColsDidSelecte(selectedIndexs, selectedValues: selectedValues)
        }
    }
    
    // 不关联的数据时直接设置默认的下标
    private var defalultSelectedIndexs: [Int]? = nil {
        didSet {
            if let defaultIndexs = defalultSelectedIndexs {
                
                defaultIndexs.enumerate().forEach({ (component: Int, row: Int) in
                    
                    assert(component < pickerView.numberOfComponents && row < pickerView.numberOfRowsInComponent(component), "设置的默认选中Indexs有不合法的")
                    if component < pickerView.numberOfComponents && row < pickerView.numberOfRowsInComponent(component){
                        
                        // 滚动到默认位置
                        
                        // 设置默认值
                        selectedIndexs[component] = row
                        selectedValues[component] = titleForRow(row, forComponent: component) ?? " "
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            self.pickerView.selectRow(row, inComponent: component, animated: false)
                        })

                    }
                    
                })
                
            } else {
                multipleColsData?.indices.forEach({ (index) in
                    // 滚动到默认位置
                    pickerView.selectRow(0, inComponent: index, animated: false)
                    
                    // 设置默认选中值
                    selectedIndexs[index] = 0
                    
                    selectedValues[index] = titleForRow(0, forComponent: index) ?? " "
                    
                })
            }
        }
    }
  
    //MARK:- 有多列关联的时候用到的属性
    private var multipleAssociatedColsData: MultipleAssociatedDataType? = nil {
        didSet {
            
            if let multipleAssociatedData = multipleAssociatedColsData {
                // 初始化选中的values
                for _ in 0...multipleAssociatedData.count {
                    selectedIndexs.append(0)
                    selectedValues.append(" ")
                }
            }
        }
    }
    
    // 多列关联数据的时候设置默认的values而没有使用默认的index
    private var defaultSelectedValues: [String]? = nil {
        didSet {
            
            if let defaultValues = defaultSelectedValues {
                // this is a wrong way cause defaultValues is less than components' count
//                selectedValues = defaultValues
                defaultValues.enumerate().forEach { (component: Int, element: String) in
                    var row: Int? = nil

                    if component == 0 {
                        let firstData = multipleAssociatedColsData![0]
                    
                        for (index,associatedModel) in firstData.enumerate() {
                            if associatedModel.first!.0 == element {
                                row = index
                                break
                            }
                        }
                    } else {
                        
                        let associatedModels = multipleAssociatedColsData![component - 1]
                        var arr: [String]?
                        
                        for associatedModel in associatedModels {

                            if associatedModel.first!.0 == defaultValues[component - 1] {
                                arr = associatedModel.first!.1
                                break
                            }
                        }
                        row = arr?.indexOf(element)
                        
                    }
                    
                    assert(row != nil, "第\(component)列设置的默认值有误")
                    if row == nil {
                        row = 0
                        print("第\(component)列设置的默认值有误")
                    }
                    if component < pickerView.numberOfComponents {
                        //                        print(" \(component) ----\(row!)")
                        
                        // 设置选中的下标
                        selectedIndexs[component] = row!
                        // 设置默认值
                        selectedValues[component] = titleForRow(row!, forComponent: component) ?? " "
                        // 滚动到默认的位置
                        dispatch_async(dispatch_get_main_queue(), { 
                            
                            self.pickerView.selectRow(row!, inComponent: component, animated: false)
                        })

                    }
                    
                }
                
                
            } else {
                for index in 0...multipleAssociatedColsData!.count {
                    // 滚动到默认的位置 0 行
                    pickerView.selectRow(0, inComponent: index, animated: false)
                    // 设置默认的选中值
                    selectedValues[index] = titleForRow(0, forComponent: index) ?? " "

                    selectedIndexs[index] = 0
                }
            }
        }
    }
    
    // MARK:- 日期选择器用到的属性
    private var selectedDate = NSDate() {
        didSet {
            delegate?.dateDidSelecte(selectedDate)
        }
    }
    private var dateDoneAction: DateDoneAction? {
        didSet {
            toolBar.doneAction = {[unowned self] in
                self.dateDoneAction?(selectedDate: self.selectedDate)
                
            }
        }
    }
    
    private lazy var pickerView: UIPickerView! = { [unowned self] in
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.whiteColor()
        return picker
    }()
    
    private lazy var datePicker: UIDatePicker = {[unowned self] in
        let datePic = UIDatePicker()
        datePic.backgroundColor = UIColor.whiteColor()
        //        print(NSLocale.availableLocaleIdentifiers())
        datePic.locale = NSLocale(localeIdentifier: "zh_CN")
        return datePic
    }()
    
    private lazy var toolBar: LPToolBarView! = LPToolBarView()
    
    //MARK:- 初始化
    public init(pickerStyle: PickerStyles) {
        let frame = CGRect(x: 0.0, y: 0.0, width: Double(screenWidth), height: toolBarHeight + pickerViewHeight)
        self.pickerStyle = pickerStyle
        super.init(frame: frame)
        setup()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
        
    private func setup() {
        addSubview(toolBar)
        
        if pickerStyle == PickerStyles.Date {
            datePicker.addTarget(self, action: #selector(self.dateDidChange(_:)), forControlEvents: UIControlEvents.ValueChanged)
            addSubview(datePicker)
        } else {
            addSubview(pickerView)
        }
    }
    
    func dateDidChange(datePic: UIDatePicker) {
        selectedDate = datePic.date
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let toolBarX = NSLayoutConstraint(item: toolBar, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let toolBarY = NSLayoutConstraint(item: toolBar, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let toolBarW = NSLayoutConstraint(item: toolBar, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0.0)
        let toolBarH = NSLayoutConstraint(item: toolBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: CGFloat(toolBarHeight))
        
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints([toolBarX, toolBarY, toolBarW, toolBarH])

        if pickerStyle == PickerStyles.Date {
            
            let pickerX = NSLayoutConstraint(item: datePicker, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0)
            let pickerY = NSLayoutConstraint(item: datePicker, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: CGFloat(toolBarHeight))
            let pickerW = NSLayoutConstraint(item: datePicker, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0.0)
            let pickerH = NSLayoutConstraint(item: datePicker, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: CGFloat(pickerViewHeight))
            
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            addConstraints([pickerX, pickerY, pickerW, pickerH])
        } else {
            
            let pickerX = NSLayoutConstraint(item: pickerView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0)
            let pickerY = NSLayoutConstraint(item: pickerView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: CGFloat(toolBarHeight))
            let pickerW = NSLayoutConstraint(item: pickerView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0.0)
            let pickerH = NSLayoutConstraint(item: pickerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: CGFloat(pickerViewHeight))
            
            pickerView.translatesAutoresizingMaskIntoConstraints = false
            addConstraints([pickerX, pickerY, pickerW, pickerH])
        }
    }
    
}
//MARK: UIPickerViewDelegate, UIPickerViewDataSource
extension LPPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    final public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        switch pickerStyle {
        case .Single:
            return singleColData == nil ? 0 : 1
        case .Multiple:
            return multipleColsData?.count ?? 0
        case .MultipleAssociated:
            return multipleAssociatedColsData == nil ? 0 : multipleAssociatedColsData!.count + 1
        default: return 0
        }
    }
    
    final public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerStyle {
        case .Single:
            return singleColData?.count ?? 0
        case .Multiple:
            return multipleColsData?[component].count ?? 0
        case .MultipleAssociated:
            if let multipleAssociatedData = multipleAssociatedColsData {
                
                if component == 0 {
                    return multipleAssociatedData[0].count
                }else {
                    let associatedDataModels = multipleAssociatedData[component - 1]
                    var arr: [String]?
                    
                    for associatedDataModel in associatedDataModels {
                        if associatedDataModel.first!.0 == selectedValues[component - 1] {
                            arr = associatedDataModel.first!.1
                        }
                    }
                    return arr?.count ?? 0
                }
            }
            return 0
        default: return 0
        }
    }
    
    final public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerStyle {
        case .Single:
            selectedIndex = row
            selectedValue = singleColData![row]
        case .Multiple:
            selectedIndexs[component] = row
            if let title = titleForRow(row, forComponent: component) {
                selectedValues[component] = title
            }
        case .MultipleAssociated:
            // 设置选中值
            
            if let title = titleForRow(row, forComponent: component) {
                selectedValues[component] = title
                selectedIndexs[component] = row
                // 更新下一列关联的值
                if component < multipleAssociatedColsData!.count {
                    pickerView.reloadComponent(component + 1)
                    // 递归
                    self.pickerView(pickerView, didSelectRow: 0, inComponent: component + 1)
                    pickerView.selectRow(0, inComponent: component + 1, animated: true)
                }
            }
        default : return
        }
    }
    
    final public func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let label = UILabel()
        label.textAlignment = .Center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.blackColor()
        label.font = UIFont.systemFontOfSize(18.0)
        label.backgroundColor = UIColor.clearColor()

        label.text = titleForRow(row, forComponent: component)
        return label
    }
    
    // Helper
    private func titleForRow(row: Int, forComponent component: Int) -> String? {
        switch pickerStyle {
        case .Single:
            return singleColData?[row]
        case .Multiple:
            return multipleColsData?[component][row]
        case .MultipleAssociated:
            
            if let multipleAssociatedData = multipleAssociatedColsData {
                
                if component == 0 {
                    return multipleAssociatedData[0][row].first!.0
                } else {
                    let associatedDataModels = multipleAssociatedData[component - 1]
                    var arr: [String]?
                    
                    for associatedDataModel in associatedDataModels {
                        if associatedDataModel.first!.0 == selectedValues[component - 1] {
                            arr = associatedDataModel.first!.1
                        }
                    }
                    if arr?.count == 0 {// 空数组
                        return nil
                    }
                    return arr?[row]
                }
            }
            return nil
        default: return nil
        }
    }

}

//MARK: 快速使用方法
extension LPPickerView {
    
    /// 单列
    public class func singleColPicker(toolBarTitle: String, singleColData: [String], defaultIndex: Int?,cancelAction: BtnAction?, doneAction: SingleDoneAction?) ->LPPickerView{
        let pic = LPPickerView(pickerStyle: .Single)
        pic.toolBarTitle = toolBarTitle
        pic.singleColData = singleColData
        pic.defalultSelectedIndex = defaultIndex
        pic.singleDoneOnClick = doneAction
        pic.cancelAction = cancelAction
        
        return pic
    }
    
    /// 多列不关联
    public class func multipleCosPicker(toolBarTitle: String, multipleColsData: [[String]], defaultSelectedIndexs: [Int]?,cancelAction: BtnAction?, doneAction: MultipleDoneAction?) ->LPPickerView{
        let pic = LPPickerView(pickerStyle: .Multiple)
        pic.toolBarTitle = toolBarTitle
        pic.multipleColsData = multipleColsData
        pic.defalultSelectedIndexs = defaultSelectedIndexs
        pic.cancelAction = cancelAction
        pic.multipleDoneOnClick = doneAction
        
        return pic
    }
    
    /// 多列关联
    public class func multipleAssociatedCosPicker(toolBarTitle: String, multipleAssociatedColsData: MultipleAssociatedDataType, defaultSelectedValues: [String]?,cancelAction: BtnAction?, doneAction: MultipleDoneAction?) ->LPPickerView{
        let pic = LPPickerView(pickerStyle: .MultipleAssociated)
        pic.toolBarTitle = toolBarTitle
        pic.multipleAssociatedColsData = multipleAssociatedColsData
        pic.defaultSelectedValues = defaultSelectedValues
        pic.cancelAction = cancelAction
        pic.multipleDoneOnClick = doneAction
        
        return pic
    }
    
    /// 城市选择器
    public class func citiesPicker(toolBarTitle: String, defaultSelectedValues: [String]?, cancelAction: BtnAction?, doneAction: MultipleDoneAction?) ->LPPickerView{
        
        let provincePath = NSBundle.mainBundle().pathForResource("Province", ofType: "plist")
        let cityPath = NSBundle.mainBundle().pathForResource("City", ofType: "plist")
        let areaPath = NSBundle.mainBundle().pathForResource("Area", ofType: "plist")
        // 这里需要使用数组, 因为字典无序, 如果只使用 cityArr,areaArr, 那么显示将是无序的, 不能按照plist中的数组显示
        let proviceArr = NSArray(contentsOfFile: provincePath!)
        let cityArr = NSDictionary(contentsOfFile: cityPath!)
        let areaArr = NSDictionary(contentsOfFile: areaPath!)
        
        var citiesModelArr: [[String: [String]?]] = []
        var areasModelArr: [[String: [String]?]] = []

        proviceArr?.forEach({ (element) in
            if let provinceStr = element as? String {
                
                let cities = cityArr?[provinceStr] as? [String]
                citiesModelArr.append([provinceStr: cities])
                
                cities?.forEach({ (city) in
                    let areas = areaArr?[city]as? [String]
                    areasModelArr.append([city: areas])
                    
                })
            }
        })
        
        let citiesArr = [citiesModelArr, areasModelArr]
    
        let pic = LPPickerView.multipleAssociatedCosPicker(toolBarTitle, multipleAssociatedColsData: citiesArr, defaultSelectedValues: defaultSelectedValues, cancelAction: cancelAction, doneAction: doneAction)
        return pic
    }
    
    /// 时间选择器
    public class func datePicker(toolBarTitle: String,
                            datePickerSetting: DatePickerSetting,
                                 cancelAction: BtnAction?,
                                   doneAction: DateDoneAction?) ->LPPickerView{
        
        let pick = LPPickerView(pickerStyle: .Date)
        pick.datePickerSetting = datePickerSetting
        pick.toolBarTitle = toolBarTitle
        pick.cancelAction = cancelAction
        pick.dateDoneAction = doneAction
        return pick
    }
    
}
