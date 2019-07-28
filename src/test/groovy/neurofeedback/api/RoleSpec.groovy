package neurofeedback.api

import grails.testing.gorm.DomainUnitTest
import spock.lang.Specification

class RoleSpec extends Specification implements DomainUnitTest<Role> {

    def setup() {
    }

    def cleanup() {
    }

    void "name cant be larger than 50"() {
        when:
            domain.name = "this string is going to be larger than 30 which is the max size of it"
        then:
            !domain.validate(['name'])
    }
}