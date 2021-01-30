import matplotlib.pyplot as plt
from icecream import ic
import emoji
from datetime import datetime


def main():
    time_fmt = "%d/%m/%Y %H:%M:%S"
    answers = lambda key: {
        "hello": "Xin chao ban Khoai",
        "are you crazy?": "No I'm not. I'm very serious!",
        "what time is it?": f"It is {datetime.now().strftime(time_fmt)}",
        "whats your name?": "My name is Alice",
        "Khoai hoc bai chua?": "Chưa!",
    }.get(key, "I dont have answer for this question")

    while True:
        question = input().strip()
        ic(answers(question))
    
    
if __name__ == '__main__':
    main()
