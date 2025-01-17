package neurofeedback.api

class MobileController{
    def passwordEncoder

    def index() {       
        render "You should not be doing this"
    }

    def auth(){
        def map

        def userJSON = request.JSON
        def docNumber = userJSON.docNumber
        def pass = userJSON.password

        def user = User.findByDocNumber(docNumber)
        if (user != null) {
            if (passwordEncoder.matches(pass, user.password)) {
                map = [status: 200, message: [response: "Successfuly logged in", userId: user.id.toString()]]

            }
            else{
                map = [status: 400, message: [response: "Error Password"]]
            }
        } else {
            map = [status: 400, message: [response: "Error User"]]
        }

        respond map, formats: ['json']
    }


    def treatments(){
        def userId = params.id

        def userTreatments = UserTreatment.findAllByUser(User.findById(userId)).stream().filter { userT ->
            userT.status == "Pending"
        }.map {
            ut -> ut.toJson()
        }.collect()

        respond userTreatments, formats: ['json']
    }

    //recibe un userTreatment_id y devuelve un unico tratamiento
    def getUserTreatment(){
        def map
        def userId = params.userTreatment_id
        def userTreatment = UserTreatment.findById(userId).toJson()
        map = [status: 200, message:userTreatment]
        respond map, formats: ['json']
    }
}


    