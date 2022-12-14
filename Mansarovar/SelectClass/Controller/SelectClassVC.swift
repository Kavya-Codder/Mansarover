//
//  SelectClassVC.swift
//  Mansarovar
//
//  Created by Sunil Developer on 05/12/22.
//

import UIKit

class SelectClassVC: UIViewController {

    @IBOutlet weak var selectClassTableView: UITableView!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    var arrOfExam: [ExamModel] = []
    var selected = -1
    var examsID = 0
    static var selectedExam: ExamModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        
        selectClassTableView.delegate = self
        selectClassTableView.dataSource = self
        selectClassTableView.register(UINib(nibName: SelectClassTVC.identifier, bundle: nil), forCellReuseIdentifier: SelectClassTVC.identifier)
        selectClassTableView.rowHeight = 80
        
        apiExam()
        
    }
    
    
    @IBAction func onClickSubmitBtn(_ sender: Any) {
        
        if selected != -1 {
            updateExam()
            
        } else {
            showAlert(title: "", message: "Please Select Class") { (str) in
                
            }
        }
    }
    
}

extension SelectClassVC: UITableViewDelegate,UITableViewDataSource {
    
    // TableView Configration
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfExam.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = selectClassTableView.dequeueReusableCell(withIdentifier: SelectClassTVC.identifier, for: indexPath) as! SelectClassTVC
        let objExam = arrOfExam[indexPath.row]
        
        cell.lblClassName.text = objExam.name
        if selected == -1 {
            if(objExam.name ?? "") == SelectClassVC.selectedExam?.name ?? "" {
                cell.imgSelect.isHidden = false
                self.selected = indexPath.row
               }else {
                cell.imgSelect.isHidden = true
                  }
           }else{
              if self.selected == indexPath.row{
                cell.imgSelect.isHidden = false
              }else{
                cell.imgSelect.isHidden = true
              }
              }
              return cell
          }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selected = indexPath.row
        
        self.selectClassTableView.reloadData()
    }


    func pushToDeshboardVC() {
        let vc = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "DeshboardVC") as! DeshboardVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func initialSetUp() {
        btnSubmit.clipsToBounds = true
        btnSubmit.layer.cornerRadius = 15
    }
    //MARK:- Api call
    
    // AllExam api

    func apiExam() {
        //self.startAnimation()
        let apiNmae = "https://eteachnow.com/mobile/app/all-exams"
        guard let url = URL(string: apiNmae) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let param = ["instid": 20, "email": "sunil12@gmail.com"] as [String : Any]
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try? JSONSerialization.data(withJSONObject: param, options: [])
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            //self.stopAnimating()
              do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as! Dictionary<String, Any>
                
                let obj = ExamBaseModel(response: json)
                if obj.status == "200" {
                    if obj.exams != nil {
                    self.arrOfExam = obj.exams
                        
                    DispatchQueue.main.async {
                        self.examsID = obj.exams.first?.c_id ?? 0
                        self.selectClassTableView.reloadData()
                        
                    }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.displayAlert(with: "Error", message: obj.msg, buttons: ["ok"]) { (str) in
                            
                        }
                    }
                }
                    
                        print(json)
                        
                    }catch {
                    
                    }
                    
            
        }.resume()
    }
    
    // update api
    
    func updateExam() {
        
        if selected != nil {
            self.examsID = arrOfExam[self.selected].c_id ?? 0
        }
       // self.startAnimation()
        let apiName = "https://eteachnow.com/mobile/app/update-exam"
        guard let url = URL(string: apiName) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let param = ["email": "sunil12@gmail.com", "examid": self.examsID, "instid": 20] as [String : Any]
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try? JSONSerialization.data(withJSONObject: param, options: [])
        URLSession.shared.dataTask(with: request) { (data, response, error) in
          //  self.stopAnimating()
              do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as! Dictionary<String, Any>
                print(json)
                
                let obj = UpdateExamModel(response: json)
                if obj.status == "200" {
                   
                    DispatchQueue.main.async {
                        self.selectClassTableView.reloadData()
                       self.tabBarController?.selectedIndex = 0
                      //  self.pushToDeshboardVC()

                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.displayAlert(with: "Error", message: obj.msg, buttons: ["ok"]) { (str) in
                            
                        }
                    }
                }
                    
                        print(json)
                        
                    }catch {
                    
                    }
                    
            
        }.resume()
    }
    
}
    
