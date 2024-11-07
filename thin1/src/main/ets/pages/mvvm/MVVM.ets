/**
 * MVVM模式
 *
 * 应用通过状态去渲染更新UI是 程序设计中相对复杂，但又十分重要的，往往决定了应用程序的性能。
 * 程序的状态数据通常包含了数组、对象，或者是嵌套对象组合而成。
 * 在这些情况下，ArkUI采取MVVM = Model + View + ViewModel模式，其中状态管理模块起到的就是ViewModel的作用，将数据与视图绑定在一起，
 * 更新数据的时候直接更新视图。
 *
 * Model层：存储数据和相关逻辑的模型。它表示组件或其他相关业务逻辑之间传输的数据。Model是对原始数据的进一步处理。
 * View层：在ArkUI中通常是@Component装饰组件渲染的UI。
 * ViewModel层：在ArkUI中，ViewModel是存储在自定义组件的状态变量、LocalStorage和AppStorage中的数据。
 *  - 自定义组件通过执行其build()方法或者@Builder装饰的方法来渲染UI，即ViewModel可以渲染View。
 *  - View可以通过相应event handler来改变ViewModel，即事件驱动ViewModel的改变，另外ViewModel提供了@Watch回调方法
 *    用于监听状态数据的改变。
 *  - 在ViewModel被改变时，需要同步回Model层，这样才能保证ViewModel和Model的一致性，即应用自身数据的一致性。
 *  - ViewModel结构设计应始终为了适配自定义组件的构建和更新，这也是将Model和ViewModel分开的原因。
 *
 *
 *   Model  <——————>   ViewModel   <------->    View
 *                    - 状态变量                - 执行build()方法
 *                    - LocalStorage           - 执行@Builder装饰的方法
 *                    - AppStorage
 *
 * 一个应用程序直接将SQL数据库中的数据读入内存，这种数据模型不能很好的直接适配自定义组件的渲染，所以在应用程序开发中需要适配ViewModel层。
 *
 * - Model：针对数据库高效操作的数据模型。
 * - ViewModel：针对ArkUI状态管理功，能进行高效的UI更新的视图模型。
 * - 部署 converters/adapters： converters/adapters作用于Model和ViewModel的相互转换。
 *    - converters/adapters可以转换最初从数据库读取的Model，来创建并初始化ViewModel。
 *    - 在应用的使用场景中，UI会通过event handler改变ViewModel，此时converters/adapters需要将ViewModel的更新数据同步回Model。
 *
 *
 *
 * ViewModel的数据源
 *
 * ViewModel通常包含多个顶层数据源。
 * @State和@Provide装饰的变量以及LocalStorage和AppStorage都是顶层数据源，其余装饰器都是与数据源做同步的数据。
 * 装饰器的选择取决于状态需要在自定义组件之间的共享范围。共享范围从小到大的排序是：
 * - @State：组件级别的共享，通过命名参数机制传递，例如：CompA: ({ aProp: this.aProp })，表示传递层级（共享范围）是父子之间的传递。
 * - @Provide：组件级别的共享，可以通过key和@Consume绑定，因此不用参数传递，实现多层级的数据共享，共享范围大于@State。
 * - LocalStorage：页面级别的共享，可以通过@Entry在当前组件树上共享LocalStorage实例。
 * - AppStorage：应用全局的UI状态存储，和应用进程绑定，在整个应用内的状态数据的共享。
 *
 * @State装饰的变量与一个或多个子组件共享状态数据
 *
 * @State可以初始化多种状态变量，@Prop、@Link和@ObjectLink可以和其建立单向或双向同步。
 * @State如果想要将更改传递给孙子节点，需要先将更改传递给子组件，再从子节点传递给孙子节点。
 * 共享只能通过构造函数的参数传递，即命名参数机制CompA: ({ aProp: this.aProp })。
 *
 * @Provide装饰的变量与任何后代组件共享状态数据
 * @Provide装饰的变量可以与任何后代组件共享状态数据，其后代组件使用@Consume创建双向同步。
 * 使用@Provide-@Consume模式时，@Consume和其祖先组件中的@Provide通过绑定相同的key连接，而不是在组件的构造函数中通过参数来进行传递。
 *
 *
 * 给LocalStorage实例中对应的属性建立双向或单向同步
 * 通过@LocalStorageLink和@LocalStorageProp，给LocalStorage实例中的属性建立双向或单向同步。
 * 可以将LocalStorage实例视为@State变量的Map。
 * LocalStorage对象可以在ArkUI应用程序的几个页面上共享。因此，使用@LocalStorageLink、@LocalStorageProp和LocalStorage可以在
 * 应用程序的多个页面上共享状态。
 *
 * 给AppStorage中对应的属性建立双向或单向同步
 * AppStorage是LocalStorage的单例对象，ArkUI在应用程序启动时创建该对象，在页面中使用@StorageLink和@StorageProp为
 * 多个页面之间共享数据，具体使用方法和LocalStorage类似。
 *
 * 也可以使用PersistentStorage将AppStorage中的特定属性持久化到本地磁盘的文件中，再次启动的时候@StorageLink和@StorageProp会
 * 恢复上次应用退出的数据。
 *
 *
 * ViewModel的嵌套场景
 *
 * 大多数情况下，ViewModel数据项都是复杂类型的，例如，对象数组、嵌套对象或者这些类型的组合。对于嵌套场景，可以使用@Observed搭配
 * @Prop或者@ObjectLink来观察变化。
 *
 * @Prop和@ObjectLink嵌套数据结构
 *
 * 推荐设计单独的自定义组件来渲染每一个数组或对象。此时，对象数组或嵌套对象（属性是对象的对象称为嵌套对象）需要两个自定义组件，
 * 一个自定义组件呈现外部数组/对象，另一个自定义组件呈现嵌套在数组/对象内的类对象。
 * @State、@Prop、@Link、@ObjectLink装饰的变量只能观察到第一层的变化。
 *
 * 1. 对于类
 *    可以观察到赋值的变化：this.obj=new ClassObj(...)
 *    可以观察到对象属性的更改：this.obj.a=new ClassA(...)
 *    不能观察更深层级的属性更改：this.obj.a.b = 47
 * 2. 对于数组：
 *    可以观察到数组的整体赋值：this.arr=[...]
 *    可以观察到数据项的删除、插入和替换：this.arr[1] = new ClassA()、this.arr.pop()、 this.arr.push(new ClassA(...))、
 *    this.arr.sort(...)
 *    不能观察更深层级的数组变化：this.arr[1].b = 47
 *
 *
 * 如果要观察嵌套类的内部对象的变化，可以使用@ObjectLink或@Prop。优先考虑@ObjectLink，其通过嵌套对象内部属性的引用初始化自身。
 * @Prop会对嵌套在内部的对象的深度拷贝来进行初始化，以实现单向同步。在性能上@Prop的深度拷贝比@ObjectLink的引用拷贝慢很多。
 *
 * @ObjectLink或@Prop可以用来存储嵌套内部的类对象，该类必须用@Observed类装饰器装饰，否则类的属性改变并不会触发更新，UI并不会刷新。
 * @Observed为其装饰的类实现自定义构造函数，此构造函数创建了一个类的实例，并使用ES6代理包装（由ArkUI框架实现），
 * 拦截装饰class属性的所有“get”和“set”。“set”观察属性值，当发生赋值操作时，通知ArkUI框架更新。“get”收集哪些UI组件依赖该状态变量，
 * 实现最小化UI更新。
 *
 *
 * 如果嵌套场景中，嵌套数据内部是数组或者class时，需根据以下场景使用@Observed类装饰器。
 * 1. 如果嵌套数据内部是class，直接被@Observed装饰。
 * 2. 如果嵌套数据内部是数组，可以通过以下方式来观察数组变化。
 *
 * @Observed class ObservedArray<T> extends Array<T> {
 *        constructor(args: T[]) {
 *            if (args instanceof Array) {
 *               super(...args);
 *            } else {
 *               super(args)
 *            }
 *        }
 *   }
 *
 *
 * 嵌套数据结构中@Prop和@ObjectLink之间的区别
 * 1. 父组件ViewB渲染@State arrA：Array<ClassA>。@State可以观察新数组的分配、数组项插入、删除和替换。
 * 2. 子组件ViewA渲染每一个ClassA的对象。
 * 3. 类装饰器@Observed ClassA与@ObjectLink a: ClassA。
 *      可以观察嵌套在Array内的ClassA对象的变化。
 *      不使用@Observed时：
 *      ViewB中的this.arrA[Math.floor(this.arrA.length/2)].c=10将不会被观察到，相应的ViewA组件也不会更新。
 *      对于数组中的第一个和第二个数组项，每个数组项都初始化了两个ViewA的对象，渲染了同一个ViewA实例。在一个ViewA中的属性赋值
 *      this.a.c += 1;时不会引发另外一个使用同一个ClassA初始化的ViewA的渲染更新。
 *
 *
 *
 * @Prop是单向数据同步，ViewA内的Button只会触发Button自身的刷新，不会传播到其他的ViewA实例中。在ViewA中的ClassA只是一个副本，
 * 并不是其父组件中@State arrA : Array<ClassA>中的对象，也不是其他ViewA的ClassA，这使得数组的元素和ViewA中的元素表面是
 * 传入的同一个对象，实际上在UI上渲染使用的是两个互不相干的对象。
 *
 * 需要注意@Prop和@ObjectLink还有一个区别：@ObjectLink装饰的变量是仅可读的，不能被赋值；@Prop装饰的变量可以被赋值。
 * 1. @ObjectLink实现双向同步，因为它是通过数据源的引用初始化的。
 * 2. @Prop是单向同步，需要深拷贝数据源。
 * 3. 对于@Prop赋值新的对象，就是简单地将本地的值覆写，但是对于实现双向数据同步的@ObjectLink，覆写新的对象相当于要更新数据源中的数组项
 *    或者class的属性，这个对于 TypeScript/JavaScript是不能实现的。
 *
 */


const TAG = "[MVVM]"


let nextId = 0;

@Observed
export class ObservedArray<T> extends Array<T> {
  constructor(args: T[]) {
    console.log(TAG, `ObservedArray: ${JSON.stringify(args)}`)
    if (args instanceof Array) {
      super(...args)
    } else {
      super(args)
    }
  }
}

@Observed
export class Address {
  street: string
  zip: number
  city: string

  constructor(street: string, zip: number, city: string) {
    this.street = street;
    this.zip = zip;
    this.city = city;
  }
}

@Observed
export class Person {
  id_: string
  name: string
  address: Address
  phones: ObservedArray<string>

  constructor(name: string, street: string, zip: number, city: string, phones: string[]) {
    this.id_ = `${nextId}`
    nextId++;
    this.name = name;
    this.address = new Address(street, zip, city);
    this.phones = new ObservedArray<string>(phones);
  }
}

export class AddressBook {
  me: Person
  contacts: ObservedArray<Person>

  constructor(me: Person, contacts: Person[]) {
    this.me = me;
    this.contacts = new ObservedArray<Person>(contacts);
  }
}


@Component
struct PersonView {
  @ObjectLink person: Person
  @ObjectLink phones: ObservedArray<string>
  @Link selectedPerson: Person

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
      Text(this.person.name)
      if (this.phones.length) {
        Text(this.phones[0])
      }
    }.height(55)
    .backgroundColor(this.selectedPerson.name == this.person.name ? '#ffa0a0' : '#ffffff')
    .onClick(() => {
      this.selectedPerson = this.person
    })
  }
}

@Component
struct PhonesNumber {
  @ObjectLink phoneNumber: ObservedArray<string>

  build() {
    Column() {
      ForEach(this.phoneNumber, (phone: ResourceStr, index?: number) => {
        TextInput({ text: phone })
          .onChange((value) => {
            this.phoneNumber[index!] = value
          })
      }, (phone: ResourceStr, index: number) => `${this.phoneNumber[index] + index}`)
    }
  }
}


@Component
struct PersonEditView {
  @Consume addrBook: AddressBook;
  @Link selectedPerson: Person;
  @Prop name: string = ""
  @Prop address: Address = new Address("", 0, "")
  @Prop phones: ObservedArray<string> = new ObservedArray([])

  selectedPersonIndex(): number {
    return this.addrBook.contacts.findIndex((person: Person) => {
      person.id_ == this.selectedPerson.id_
    })
  }

  build() {
    Column() {
      TextInput({ text: this.name })
        .onChange((value) => {
          this.name = value
        })
      TextInput({ text: this.address.street })
        .onChange((value) => {
          this.address.street = value
        })
      TextInput({ text: this.address.city })
        .onChange((value) => {
          this.address.city = value
        })
      TextInput({ text: this.address.zip.toString() })
        .onChange((value) => {
          const result = Number.parseInt(value)
          this.address.zip = Number.isNaN(result) ? 0 : result
        })

      if (this.phones.length > 0) {
        PhonesNumber({ phoneNumber: this.phones })
      }

      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
        Button('Save Changes')
          .onClick(() => {
            this.selectedPerson.name = this.name
            this.selectedPerson.address = new Address(this.address.street, this.address.zip, this.address.city)
            this.phones.forEach((phone: string, index: number) => {
              this.selectedPerson.phones[index] = phone
            })
          })


        if (this.selectedPersonIndex() != -1) {
          Button('Delete Contact')
            .onClick(() => {
              let index = this.selectedPersonIndex()
              this.addrBook.contacts.slice(index, 1)
              index = (index < this.addrBook.contacts.length) ? index : index - 1
              this.selectedPerson = (index >= 0) ? this.addrBook.contacts[index] : this.addrBook.me
            })
        }

      }

    }
  }
}


@Component
struct AddressBookView {
  @ObjectLink me: Person
  @ObjectLink contacts: ObservedArray<Person>
  @State selectedPerson: Person = new Person("", "", 0, "", [])

  aboutToAppear(): void {
    this.selectedPerson = this.me
  }

  build() {

    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
      Text('Me:')
      PersonView({
        person: this.me,
        phones: this.me.phones,
        selectedPerson: this.selectedPerson
      })

      Divider().height(8)

      ForEach(this.contacts, (contact: Person) => {

        PersonView({
          person: contact,
          phones: contact.phones,
          selectedPerson: this.selectedPerson
        })

      }, (contact: Person) => {
        return contact.id_
      })

      Divider().height(8)

      Text('Edit:')
      PersonEditView({
        selectedPerson: this.selectedPerson,
        name: this.selectedPerson.name,
        address: this.selectedPerson.address,
        phones: this.selectedPerson.phones
      })

    }
    .borderStyle(BorderStyle.Solid).borderWidth(5).borderColor(0xAFEEEE).borderRadius(5)
  }
}


@Entry
@Component
struct PageEntry {
  @Provide addrBook: AddressBook = new AddressBook(
    new Person("Gigi", "Itamerenkatu 9", 180, "Helsinki", ["18100000001", "18100000002"]),
    [
      new Person("Oly", "Itamerenkatu 9", 180, "Helsinki", ["11000000001", "12000000002"]),
      new Person("Sam", "Itamerenkatu 9", 180, "Helsinki", ["13000000002", "14000000005"]),
      new Person("Vivi", "Itamerenkatu 9", 180, "Helsinki", ["15000000001", "16800000002"]),
    ]);

  build() {
    Column(){
      AddressBookView({
        me: this.addrBook.me,
        contacts: this.addrBook.contacts,
        selectedPerson: this.addrBook.me
      })
    }
  }
}






















