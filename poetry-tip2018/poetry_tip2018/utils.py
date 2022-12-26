import cv2


class Image:
    def __init__(self, image_path=None):
    '''
    This class is designed to be as an opencv
    wrapper. 

    @arguments: 

    @return: 
    '''
        if image_path != None:
            self.image = cv2.imread(image_path)
            self.height = 0
            self.width = 0
        else:
            self.image = None
            self.height = 0
            self.width = 0

    def add_image_path(self, image_path):
        self.image_path = image_path

    def _find_edges(self):
        self.edge = Edge(self.image)


class Edge:
    def __init__(self, Image):
        self.edge_map = cv2.find_edges(Image.image)

