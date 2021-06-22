





import UIKit

class viewControllerEditarPerfil: UIViewController {

    var usuario:Users? = nil
    @IBOutlet weak var txtUsuario: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtContraseña: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(usuario!.nombre)
        //print(usuario!.email)
        txtUsuario.text = usuario!.nombre
        txtEmail.text = usuario!.email
        txtContraseña.text = usuario!.clave
    }
    
    func metodoPUT(ruta:String, datos:[String:Any]){
        let url:URL = URL(string: ruta)!
        var request = URLRequest(url: url)
        let session = URLSession.shared
        request.httpMethod = "PUT"

        let params = datos

        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        }catch{

        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(with: request, completionHandler: {(data,respomse,error) in
            if(data != nil){
                do{
                    let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves)
                    print(dict)
                }catch{

                }
            }
        })
        task.resume()
    }
    
    @IBAction func botonActualizarPerfil(_ sender: Any) {
        let id = self.usuario!.id
        let nombre = txtUsuario.text!
        let email = txtEmail.text!
        let contraseña = txtContraseña.text!
        var datos = ["id": "\(id)","nombre": "\(nombre)","email": "\(email)"] as Dictionary<String,Any>
        
        if nombre=="" || email=="" || contraseña.count==0 {
            let alerta = UIAlertController(title: "Error", message: "Algun(os) campo(s) esta(n) vacio(s), es necesario llenarlos", preferredStyle: .alert)
            let btnCANCELOK = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
            alerta.addAction(btnCANCELOK)
            present(alerta, animated: true, completion: nil)
        }else{
            print(contraseña)
            datos = ["id": "\(id)","nombre": "\(nombre)","clave": "\(contraseña)","email": "\(email)"] as Dictionary<String,Any>
            
            let ruta = "http://localhost:3000/usuarios/\(usuario!.id)"
            metodoPUT(ruta: ruta, datos: datos)
            navigationController?.popViewController(animated: true)
        }
    }
}
