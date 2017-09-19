# import cv2
#
# import numpy as np
#
# def get_dist_w_fl(image):
#
#     img = cv2.imread(image)
#
#     def find_marker(pic):
#
#         gray = cv2.GaussianBlur(pic, (5, 5), 0)
#
#         edged = cv2.Canny(gray, 35, 125)
#
#         (_, cnts, _) = cv2.findContours(edged.copy(), cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
#
#         c = max(cnts, key=cv2.contourArea)
#
#         # compute the bounding box of the of the paper region and return it
#
#         return cv2.minAreaRect(c)
#
#     def find_blue(image):
#
#         boundaries = [
#
#             ([86, 31, 4], [220, 88, 50]),
#
#         ]
#
#         for (lower, upper) in boundaries:
#
#             lower = np.array(lower, dtype="uint8")
#
#             upper = np.array(upper, dtype="uint8")
#
#             mask = cv2.inRange(image, lower, upper)
#
#         return mask
#
#     def distance_to_camera(knownWidth, focalLength, perWidth):
#
#         # compute and return the distance from the maker to the camera
#
#         return (knownWidth * focalLength) / perWidth
#
#     KNOWN_WIDTH = 0.1
#
#     focalLength = 2000.0
#
#     mask = find_blue(img)
#
#     marker = find_marker(mask)
#
#     meters = distance_to_camera(KNOWN_WIDTH, focalLength, marker[1][0])
#
#     # box = np.int0(cv2.boxPoints(marker))
#     #
#     # cv2.drawContours(img, [box], -1, (0, 255, 0), 2)
#     #
#     # cv2.putText(img, str(meters) + "m",
#     #
#     #             (img.shape[1] - 200, img.shape[0] - 20), cv2.FONT_HERSHEY_SIMPLEX,
#     #
#     #             2.0, (0, 255, 0), 3)
#
#     # cv2.imshow("image", img)
#
#     # cv2.waitKey(0)
#
#     return meters
#
# if __name__ == "__main__":
#     #fn = '/home/osboxes/PycharmProjects/42-orbital-rendevous/Screenshots/realistic2.ppm'
#     # fn = '/home/osboxes/PycharmProjects/42-orbital-rendevous/Screenshots/CamFrame000291.ppm'
#     fn = '/home/osboxes/PycharmProjects/42-orbital-rendevous/Screenshots/CamFrame000291.ppm'
#     print(get_dist_w_fl(fn))

print("({0:3.2f} {1})".format(2,3))
