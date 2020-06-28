//
//  UserCreate.swift
//  Palpito_v0.01
//
//  Created by 김정식 on 28/09/2018.
//  Copyright © 2018 김정식. All rights reserved.
//

import Foundation

class UserCreate {
    
    var UserInfoList = UserInfo()
    
    func emailAdd(email:String) -> UserInfo?{
        UserInfoList.email = email
        return UserInfoList
    }
    
    func nameAdd(name:String) -> String?{
        UserInfoList.name = name
        return UserInfoList.name
    }
    
    func passwordAdd(password:String) -> String?{
        UserInfoList.password = password
        return UserInfoList.password
    }
    
    func userCreateAdd(email:String, password:String, nickName:String, birth:String) -> UserInfo?{
        UserInfoList.email      = email
        UserInfoList.password   = password
        UserInfoList.name       = nickName
        UserInfoList.birth      = birth
        
        return UserInfoList
    }
    
    func ageAdd(age:Int) -> Int?{
        UserInfoList.age = age
        return UserInfoList.age
    }
    
    func genderAdd(gender:String) -> String?{
        UserInfoList.gender = gender
        return UserInfoList.gender
    }
    
    func createDateAdd(UserObeject:UserInfo){
        UserInfoList.createDate = UserObeject.createDate
    }
    
    func updateDateAdd(UserObeject:UserInfo){
        UserInfoList.updateDate = UserObeject.updateDate
    }
    
}
