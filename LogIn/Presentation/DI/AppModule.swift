//
//  AppModule.swift
//  LogIn
//
//  Created by Juan Armando Frías Ramírez on 22/09/23.
//

import Foundation
import Resolver
import Alamofire


extension Resolver : ResolverRegistering {
    
    public static func registerAllServices() {
        
        register { RequestInterceptor() }.implements(Alamofire.RequestInterceptor.self)
        register { Session(interceptor: optional()) }
        register { APIManager(sessionManager: resolve()) }
        
        register { LoginRepositoryImpl() }.implements(LoginRepository.self)
        
        register { LoginViewModel() }
    }
}
