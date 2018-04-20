from app import app
from flask import jsonify
import pyrebase
import networkx as nx

# from Firebase
apiKey = "AIzaSyCm9smWe1pG84yGqfw3vtmuBDsZ2c4xXG4"
projectId = "courserec-f2632"
databaseName = "courserec-f2632"

config = {
  "apiKey": apiKey,
  "authDomain": "%s.firebaseapp.com" % projectId,
  "databaseURL": "https://%s.firebaseio.com" % databaseName,
  "storageBucket": ""
}

firebase = pyrebase.initialize_app(config)

# Get a reference to the database service
db = firebase.database()

class Course:
    def __init__(self, name, title, description, prereq, units):
        self.name = name
        self.title = title
        self.description = description
        self.prereq = prereq
        self.units = units
    def __repr__(self):
        return "<Course name:%s>" % self.name
    def __str__(self):
        return "<Course name:%s>" % self.name
    def serialize(self):
        return {
            'name': self.name, 
            'title': self.title,
            'description': self.description,
            'prereq': self.prereq,
            'units': self.units
        }

courses = {
  'math1300': Course('MATH 1300', 'Trigonometry and Analytic Geometry', 'Definitions, properties and graphs of the trigonometric functions. Applications. Analytic geometry of conic sections. A preparatory course for calculus.', 'MATH 1130 or departmental permission. Must complete course with a grade of “C-” or better in order to earn General Education, Area B4, credit', '4'),
  'math1304': Course('MATH 1304', 'Calculus I', 'Differential calculus. Limits and continuity. Exponential and logarithmic functions. Techniques and applications of differentiation.', 'MATH 1300 or departmental permission. Must complete course with a grade of “C-” or better in order to earn General Education, Area B4, credit', '4'),
  'math1305': Course('MATH 1305', 'Calculus II', 'Integral calculus. The indefinite integral, area, the Fundamental Theorem and techniques of integration. Applications to volume, arc length, physical and biological problems.', 'MATH 1304', '4'),
  'math2304': Course('MATH 2304', 'Calculus III', 'Infinite series, convergence of power series. Vectors in space. Partial derivatives, chain rule, directional derivative and gradient. Curves and surfaces. Maxima and minima. Multiple integrals.', 'MATH 1305', '4'),
  'math2150': Course('MATH 2150', 'Discrete Structures', 'Topics in discrete mathematics. Elementary logic, set theory, and relations; induction, enumeration techniques, recurrence relations, trees and graphs. Boolean algebra, algorithm analysis.', 'MATH 1304', '4'),
  'math2101': Course('MATH 2101', 'Elements of Linear Algebra', 'Vector spaces, linear transformations, matrices, systems of linear equations. Stress on 2 and 3 dimensions, including geometric and other applications.', 'MATH 1305', '4'),
  'stat3601': Course('STAT 3601', 'Statistics and Probability for Science and Engineering I', 'Basic probability rules (independence, Bayes’ Theorem), distributions (binomial, Poisson, normal, exponential), reliability. Descriptive, inferential statistics (control charts, estimation, hypothesis testing: one, two samples), correlation, regression. Emphasizes: computer analysis, simulation; science, engineering applications.', 'MATH 1305', '4'),
  'stat3401': Course('STAT 3401', 'Introduction to Probability Theory I', 'The theory of probability with applications to science and engineering. Sample spaces; random variables; joint, marginal, conditional distributions; expectations; important distributions (binomial, Poisson, normal, etc.); and moment generating functions.', 'NONE', '4'),
  'cs1160': Course('CS 1160', 'Introduction to Computer Science I', 'An introduction to computers and computer science, problem solving, algorithms, and program design. Use of Interactive Development Environment (IDE’s). Programming in C++. Topics include input and output, text files, control structures, functions, arrays. Students with no computer experience are encouraged to take CS 1020 as preparation for this course.', 'MATH 1300 or equivalent', '4'),
  'cs2360': Course('CS 2360', 'Introduction to Computer Science II', 'Continuation of CS 1160. Focuses on algorithm development, structured program design, testing, and debugging. Topics include abstract data types, pointers, linked lists, recursion. Introduction to classes.', 'CS 1160', '4'),
  'cs2370': Course('CS 2370', 'Introduction to Computer Science III', 'Continuation of CS 2360. Further development of programming and problem solving skills in Computer Science. Topics include elementary data structures (stacks and queues), object oriented design, and more on searching, sorting and other algorithms.', 'CS 2360', '4'),
  'cs2430': Course('CS 2430', 'Computer Organization and Assembly Language Programming', 'Functional organization of digital computers and programming in machine and assembly language. Internal representation of data, binary arithmetic, machine instructions, addressing modes, subroutine linkage, macros. Introduction to assemblers, linkers, and loaders.', 'An introductory programming course', '4'),
  'cs3120': Course('CS 3120', 'Programming Language Concepts', 'Survey and critical comparison of a variety of computer languages. Issues include syntax, semantics, control structures, data representation. Discussion of both design and implementation; of both imperative and declarative languages.', 'CS 2360 and CS 2430', '4'),
  'cs3240': Course('CS 3240', 'Data Structures and Algorithms', 'Definition, design, implementation of abstract data structures, including hash tables, trees, graphs. Design, implementation, and analysis of algorithms for these data structures.', 'MATH 2150, CS 2370, CS 2430', '4'),
  'cs3340': Course('CS 3340', 'Introduction to Object-Oriented Programming and Design', 'Programming in an object-oriented language, using object-oriented techniques and concepts. Classes, operator overloading, information hiding, inheritance, and polymorphism. Memory management. Parameterized classes. Exception handling. Object-oriented design of programs.', 'CS 3240', '4'),
  'cs3430': Course('CS 3430', 'Computer Architecture', 'Logical design of digital computers. Boolean algebra, combinational and sequential circuits, computer arithmetic, memories, integrated circuits, control processors, input/output. No electronics experience needed.', 'MATH 2150, CS 2430', '4'),
  'cs4560': Course('CS 4560', 'Operating Systems', 'Principles of operating system design and implementation. Concurrent processes, interprocess communication, job and process scheduling; deadlock. Issues in memory management (virtual memory, segmentation, paging) and auxiliary storage management (file systems, directory structuring, protection mechanisms). Performance issues. Case studies.', 'CS 3240 and CS 3430', '4'),
  'cs3560': Course('CS 3560', 'Introduction to Systems Programming', 'Introduction to systems programming in a modern environment. Introduction to fundamental concepts of operating systems; analysis of a particular operating system (organization, interfaces, system calls, files, process control and communication, resource sharing). Shell and C programming. Development tools.', 'CS 2360', '4'),
  'cs3590': Course('CS 3590', 'Data Communications and Networking', 'Fundamentals of data communications: media, transmission, encoding and processing, interfacing, error detection and handling, link control, multiplexing, circuit and packet switching. Introduction to network architecture and topology: local and wide area networks', 'CS 2370 and CS 3430', '4'),
  'cs4590': Course('CS 4590', 'Computer Networks', 'Computer network analysis, design, and implementation. A detailed study of the network, transport and application layers of the TCP/IP model. Specific emphasis on protocols, services, design issues and performance. Programming assignments using TCP/IP.', 'CS 3240, CS 3560 and CS 3590', '4'),
  'cs3520': Course('CS 3520', 'Web Site Development', 'Web servers and browsers. HTML, images, audio and video files, indexer, forms, CGI scripts, Java programming, JavaScript.', 'CS 3240', '4'),
  'cs4110': Course('CS 4110', 'Compiler Design', 'Design and construction of high-level language translators. Formal language theory, parsing algorithms, interpreting, code generation, optimization. Construction of a small compiler.', 'CS 3120, CS 3240', '4'),
  'cs4170': Course('CS 4170', 'Theory of Automata', 'Formal models of automata, language, and computability and their relationships. Finite automata and regular languages. Pushdown automata and context-free languages. Turing machines, recursive functions, algorithms and decidability.', 'MATH 1305, MATH 2101, MATH 2150', '4'),
  'cs4245': Course('CS 4245', 'Analysis of Algorithms', 'Design, analysis and implementation of algorithms. Methods of algorithm design, including recursion, divide and conquer, dynamic programming, backtracking. Time and space complexity analyses in the best, worst, and average cases. NP-completeness; computationally hard problems. Applications from several areas of Computer Science.', 'MATH 1305, MATH 2101, CS 3240', '4'),
  'cs4310': Course('CS 4310', 'Software Engineering', 'Concepts and issues in the development of large software projects. Systematic approaches to requirements, analysis, design, implementation, testing, and maintenance of high-quality software.', 'CS 3240', '4'),
  'cs4311': Course('CS 4311', 'Software Engineering II', 'Continuation of Software Engineering I with emphasis on the object-oriented design to implementation stages of the life cycle. Design methodologies including the Unified Modeling Language, illustrated with example design patterns. Implementation in Java. Topics include standards, documentation, instrumentation, testing.', 'CS 3340, CS 4310', '4'),
  'cs4320': Course('CS 4320', 'Software Testing and Quality Assurance', 'Concepts and issues in the testing and quality control of large software projects. Topics include white box, black box, unit, integration, and validation testing; quality assurance through planning, review, and use of software metrics.', 'CS 3240', '4'),
  'cs4435': Course('CS 4435', 'Computer Architecture II', 'Advanced computer organization and design. Topics chosen from among RISC architectures, computer arithmetic, pipelining, cache memory and parallel processors. Recommended prerequisite: knowledge of C programming. ', 'CS 3430', '4'),
  'cs4521': Course('CS 4521', 'Mobile & Topics in Web Programming', 'Current practices and trends in software design, development, and deployment of mobile and new web applications and systems. Topics include modern mobile device application development, web technologies, social application development, pervasive computing and semantic web.', 'CS 3520', '4'),
  'cs4596': Course('CS 4596', 'Wireless and Mobile Networking', 'Network protocols and mechanisms to support mobility, e.g., Mobile-IP, M-RSVP, proxies. Issues including routing, tunneling, security, and handoffs. Wireless communication standards including AMPS, IS-95, GSM, PCS, and satellite standards. Underlying technologies including multiplexing and coding.', 'CS 3590', '4'),
  'cs4660': Course('CS 4660', 'Database Architecture', 'Relational, network, and hierarchical data models. Data description and data manipulation languages. Schemas, query processing, database system architecture. Integrity, concurrency, and security techniques. Distributed databases.', 'CS 3240', '4'),
  'cs4525': Course('CS 4525', 'Principles of Network Security', 'Computer network security fundamentals. Cryptography (Symmetric key algorithms and Public key algorithms). Authentication and identification, message integrity techniques. Access control and key management. Wireless security. Discussion of particular protocols, e.g., IPSEC, TLS, PGP, S/MIME, etc.', 'CS 3590', '4'),
  'cs4810': Course('CS 4810', 'Artificial Intelligence', '“Intelligent” computer programs and models of human intelligence. Game playing, robotics, computer vision, understanding natural language, knowledge engineering, computer learning.', 'CS 3240', '4'),
}

G = nx.DiGraph()

def initRecCoursesGraph():
    # add edges for courses with prereq: MATH 1300
    G.add_edge(courses['math1300'], courses['cs1160'])
    G.add_edge(courses['math1300'], courses['math1304'])

    # add edges for courses with prereq: MATH 1304
    G.add_edge(courses['math1304'], courses['math2150'])
    G.add_edge(courses['math1304'], courses['math1305'])

    # add edges for courses with prereq: MATH 1305
    G.add_edge(courses['math1305'], courses['math2304'])
    G.add_edge(courses['math1305'], courses['math2101'])
    G.add_edge(courses['math1305'], courses['stat3601'])

    # no edges for STAT 3401
    G.add_node(courses['stat3401'])
    
    # add edges for courses with prereq: CS 1160
    G.add_edge(courses['cs1160'], courses['cs2360'])
    G.add_edge(courses['cs1160'], courses['cs2430'])

    # add edges for courses with prereq: CS 2360
    G.add_edge(courses['cs2360'], courses['cs2370'])
    G.add_edge(courses['cs2360'], courses['cs3560'])

    # add edges for courses with prereq: CS 2360 and CS 2430
    G.add_edge(courses['cs2360'], courses['cs3120'])
    G.add_edge(courses['cs2430'], courses['cs3120'])

    # add edges for courses with prereq: MATH 2150, CS 2370, CS 2430
    G.add_edge(courses['math2150'], courses['cs3240'])
    G.add_edge(courses['cs2370'], courses['cs3240'])
    G.add_edge(courses['cs2430'], courses['cs3240'])

    # add edges for courses with prereq: CS 3240
    G.add_edge(courses['cs3240'], courses['cs3340'])
    G.add_edge(courses['cs3240'], courses['cs3520'])
    G.add_edge(courses['cs3240'], courses['cs4310'])
    G.add_edge(courses['cs3240'], courses['cs4320'])
    G.add_edge(courses['cs3240'], courses['cs4660'])
    G.add_edge(courses['cs3240'], courses['cs4810'])

    # add edges for courses with prereq: MATH 2150, CS 2430
    G.add_edge(courses['math2150'], courses['cs3430'])
    G.add_edge(courses['cs2430'], courses['cs3430'])

    # add edges for courses with prereq: CS 3240 and CS 3430
    G.add_edge(courses['cs3240'], courses['cs4560'])
    G.add_edge(courses['cs3430'], courses['cs4560'])
    
    # add edges for courses with prereq: CS 2370 and CS 3430
    G.add_edge(courses['cs2370'], courses['cs3590'])
    G.add_edge(courses['cs3430'], courses['cs3590'])

    # add edges for courses with prereq: CS 3240, CS 3560 and CS 3590
    G.add_edge(courses['cs3240'], courses['cs4590'])
    G.add_edge(courses['cs3560'], courses['cs4590'])
    G.add_edge(courses['cs3590'], courses['cs4590'])
    
    # add edges for courses with prereq: CS 3120, CS 3240
    G.add_edge(courses['cs3120'], courses['cs4110'])
    G.add_edge(courses['cs3240'], courses['cs4110'])

    # add edges for courses with prereq: MATH 1305, MATH 2101, MATH 2150
    G.add_edge(courses['math1305'], courses['cs4170'])
    G.add_edge(courses['math2101'], courses['cs4170'])
    G.add_edge(courses['math2150'], courses['cs4170'])

    # add edges for courses with prereq: MATH 1305, MATH 2101, CS 3240
    G.add_edge(courses['math1305'], courses['cs4245'])
    G.add_edge(courses['math2101'], courses['cs4245'])
    G.add_edge(courses['cs3240'], courses['cs4245'])

    # add edges for courses with prereq: CS 3340, CS 4310
    G.add_edge(courses['cs3340'], courses['cs4311'])
    G.add_edge(courses['cs4310'], courses['cs4311'])

    # add edges for courses with prereq: CS 3430
    G.add_edge(courses['cs3430'], courses['cs4435'])

    # add edges for courses with prereq: CS 3520
    G.add_edge(courses['cs3520'], courses['cs4521'])

    # add edges for courses with prereq: CS 3590
    G.add_edge(courses['cs3590'], courses['cs4596'])
    G.add_edge(courses['cs3590'], courses['cs4525'])

initRecCoursesGraph()

def getRecommendedCourses(userUID):
    result = []
    userCourses = db.child("users").child(userUID).child("courses").get().val()
    courseNames = set([key for key in userCourses])

    for name in courseNames:
        coursesDictKey = ''.join(name.split()).lower()
        for adjNode, _ in G.adj[courses[coursesDictKey]].items():
            if adjNode.name not in courseNames:
                result.append(adjNode)

    return result

@app.route('/api/recommended-courses/<user_uid>', methods=['GET'])
def get_recommended_courses(user_uid):
    recommendedCourses = getRecommendedCourses(user_uid)
    serializedCourses = [course.serialize() for course in recommendedCourses]
    return jsonify(serializedCourses)
