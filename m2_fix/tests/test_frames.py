import unittest

from bitstream.frames import diff_bits_in_frame, diff_frame_indices, frame_hash


class FrameHelperTests(unittest.TestCase):
    def test_frame_hash_is_stable_and_payload_only(self):
        a = [[1, 2, 3], [4, 5, 6]]
        b = [[1, 2, 3], [4, 5, 6]]
        c = [[1, 2, 3], [4, 5, 7]]
        self.assertEqual(frame_hash(a), frame_hash(b))
        self.assertNotEqual(frame_hash(a), frame_hash(c))

    def test_diff_rejects_unequal_frame_counts(self):
        with self.assertRaises(ValueError):
            diff_frame_indices([[1]], [[1], [2]])

    def test_diff_bits_rejects_unequal_frame_counts(self):
        with self.assertRaises(ValueError):
            diff_bits_in_frame([[1]], [[1], [2]], 0)


if __name__ == "__main__":
    unittest.main()
