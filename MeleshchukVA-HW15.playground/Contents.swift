import UIKit

// Исследуйте код ниже и напишите, какие цифры должны вывестись в консоль,
// обьясните своими словами, почему именно такая последовательность по шагам.

func testQueue() {
    print("1") // 1 выводится в консоль первым, т.к выполняется синхронно.

    DispatchQueue.main.async {
        print("2") // 2 выводится после 1 и 9, т.к. выполняется асинхронно.

        DispatchQueue.global(qos: .background).sync {
            print("3") // 3 выведется после 2, т.к выполняется синхронно.

            DispatchQueue.main.sync { // Дедлок из-за main.sync, ничего не выведится в консоль в скобках.
                print("4")
                
                DispatchQueue.global(qos: .background).async {
                    print("5")
                }
                print("6")
            }

            print("7") // Не выведется в консоль из-за deadlock'а выше.
        }

        print("8") // Не выведется в консоль из-за deadlock'а выше.
    }

    print("9") // 9 выводится в консоль после 1, т.к выполняется синхронно.
}

//testQueue() // 1, 9, 2, 3



// Создайте свою серийную очередь и замените в примере ею DispatchQueue.main.
// Создайте свою конкурентную очередь и заменить ей DispatchQueue.global(qos: .background).
// Какой будет результат? Всегда ли будет одинаковым. И почему?

func printSerialQueue() {
    let serialQueue = DispatchQueue(label: "serial")

    print("1")

    serialQueue.async {
        print("2")

        DispatchQueue.global(qos: .background).sync {
            print("3")

            serialQueue.sync { // Дедлок их-за main.sync, ничего не выведится в консоль в скобках.
                print("4")
                
                DispatchQueue.global(qos: .background).async {
                    print("5")
                }
                print("6")
            }

            print("7") // Не выведется в консоль из-за deadlock'а выше.
        }

        print("8") // Не выведется в консоль из-за deadlock'а выше.
    }

    print("9")
}

// Результат отличен от testQueue().
// Известно только, что print("1") всегда будет выполняться первым, т.к. выполняется синхронно.
// Дальше принтится либо 9, 2, 3, либо 2, 3, 9 из-за непредсказуемости результата серийной очереди, выполняющейся асинхронно.
//printSerialQueue()

func printConcurrentQueue() {
    let concurrentQueue = DispatchQueue(label: "concurrent", attributes: .concurrent)

    print("1")

    DispatchQueue.main.async {
        print("2")

        concurrentQueue.sync {
            print("3")

            DispatchQueue.main.sync {
                print("4")
                
                DispatchQueue.global(qos: .background).async {
                    print("5")
                }
                print("6")
            }

            print("7")
        }

        print("8")
    }

    print("9")
}

//printConcurrentQueue() // Результат такой же, как в testQueue: 1, 9, 2, 3.



// Какой по номеру надо поменять sync/sync чтобы не возникало дедлока в обоих случаях.
// Чтобы не возникало дедлока в обоих, достаточно, чтобы main-поток не выполнялся синхронно.

func printNoDeadlockConcurrentQueue() {
    let concurrentQueue = DispatchQueue(label: "concurrent", attributes: .concurrent)

    print("1")

    DispatchQueue.main.async {
        print("2")

        concurrentQueue.sync {
            print("3")

            DispatchQueue.main.async {
                print("4")
                DispatchQueue.global(qos: .background).async {
                    print("5")
                }
                print("6")
            }

            print("7")
        }

        print("8")
    }

    print("9")
}

//printNoDeadlockConcurrentQueue() // 1, 9, 2, 3, 7, 8, 4, 6, 5



// Как можно сделать в примере, чтобы очередь превратилась из конкурентной в серийную?
// Подправьте пример, не исправляя создания самой очереди.

func printConcurrentToSerialQueue() {
    let concurrentQueue = DispatchQueue(label: "concurrent", attributes: .concurrent)

    print("1")

    concurrentQueue.async {
        print("2")

        DispatchQueue.main.sync {
            print("3")

            DispatchQueue.main.sync {
                print("4")
                
                DispatchQueue.global(qos: .background).async {
                    print("5")
                }
                print("6")
            }

            print("7")
        }

        print("8")
    }

    print("9")
}

printConcurrentToSerialQueue() // Результат такой же, как и в printSerialQueue().
