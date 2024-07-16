/**
 * @Observed装饰器和@ObjectLink装饰器：嵌套类对象属性变化
 *
 *
 * @ObjectLink和@Observed类装饰器用于在涉及嵌套对象或数组的场景中进行双向数据同步：
 *
 *  - 被@Observed装饰的类，可以被观察到属性的变化；
 *  - 子组件中@ObjectLink装饰器装饰的状态变量用于接收@Observed装饰的类的实例，和父组件中对应的状态变量建立双向数据绑定。
 *    这个实例可以是数组中的被@Observed装饰的项，或者是class object中的属性，这个属性同样也需要被@Observed装饰。
 *  - @Observed用于嵌套类场景中，观察对象类属性变化，要配合自定义组件使用，
 *    如果要做数据双/单向同步，需要搭配@ObjectLink或者@Prop使用。
 *
 *
 *  使用@Observed装饰class会改变class原始的原型链，@Observed和其他类装饰器装饰同一个class可能会带来问题。
 * @ObjectLink装饰器不能在@Entry装饰的自定义组件中使用。
 *
 * @Observed类装饰器
 *
 *  装饰器参数       无
 *  类装饰器         装饰class。需要放在class的定义前，使用new创建类对象。
 *
 *
 * @ObjectLink变量装饰器
 *
 * 装饰器参数        无
 * 允许装饰的变量类型  必须为被@Observed装饰的class实例，必须指定类型。
 *                  不支持简单类型，可以使用@Prop。
 *                  支持继承Date、Array的class实例，支持继承Map、Set的class实例。
 *                  支持@Observed装饰类和undefined或null组成的联合类型
 * @ObjectLink的属性是可以改变的，但是变量的分配是不允许的，也就是说这个装饰器装饰变量是只读的，不能被改变。
 * 被装饰变量的初始值  不允许。
 *
 *
 * @ObjectLink装饰的变量不能被赋值，如果要使用赋值操作，请使用@Prop。
 * - @Prop装饰的变量和数据源的关系是是单向同步，@Prop装饰的变量在本地拷贝了数据源，所以它允许本地更改，
 *    如果父组件中的数据源有更新，@Prop装饰的变量本地的修改将被覆盖；
 * - @ObjectLink装饰的变量和数据源的关系是双向同步，@ObjectLink装饰的变量相当于指向数据源的指针。
 *    禁止对@ObjectLink装饰的变量赋值，如果一旦发生@ObjectLink装饰的变量的赋值，则同步链将被打断。
 *    因为@ObjectLink装饰的变量通过数据源（Object）引用来初始化。对于实现双向数据同步的@ObjectLink，
 *    赋值相当于更新父组件中的数组项或者class的属性，TypeScript/JavaScript不能实现，会发生运行时报错。
 *
 *
 * 变量的传递/访问规则说明
 *
 * @ObjectLink传递
 *
 * 从父组件初始化     必须指定。
 *                    初始化@ObjectLink装饰的变量必须同时满足以下场景：
 *                      - 类型必须是@Observed装饰的class。
 *                      - 初始化的数值需要是数组项，或者class的属性。
 *                      - 同步源的class或者数组必须是@State，@Link，@Provide，@Consume或者@ObjectLink装饰的数据。
 * 与源对象同步      双向。
 * 可以初始化子组件   允许，可用于初始化常规变量、@State、@Link、@Prop、@Provide
 *
 *
 * @ObjectLink只能接收被@Observed装饰class的实例，推荐设计单独的自定义组件来渲染每一个数组或对象。
 * 此时，对象数组或嵌套对象（属性是对象的对象称为嵌套对象）需要两个自定义组件，
 * 一个自定义组件呈现外部数组/对象，另一个自定义组件呈现嵌套在数组/对象内的类对象。可以观察到：
 *  1. 其属性的数值的变化，其中属性是指Object.keys(observedObject)返回的所有属性
 *  2. 如果数据源是数组，则可以观察到数组item的替换，如果数据源是class，可观察到class的属性的变化
 *
 * 继承Date的class时，可以观察到Date整体的赋值
 * 继承Map的class时，可以观察到Map整体的赋值，同时可通过调用Map的接口set, clear, delete 更新Map的值。
 * 继承Set的class时，可以观察到Set整体的赋值，同时可通过调用Set的接口add, clear, delete 更新Set的值。
 *
 *
 * 框架行为
 *
 * 1. 初始渲染：
 *  a. @Observed装饰的class的实例会被不透明的代理对象包装，代理了class上的属性的setter和getter方法
 *  b. 子组件中@ObjectLink装饰的从父组件初始化，接收被@Observed装饰的class的实例，
 *      @ObjectLink的包装类会将自己注册给@Observed class。
 * 2. 属性更新：
 *    当@Observed装饰的class属性改变时，会走到代理的setter和getter，然后遍历依赖它的@ObjectLink包装类，通知数据更新。
 */

@Entry
@Component
struct EObjectLink {
  build() {

    Column() {
      EObjectLinkViewB()
    }

  }
}

@Observed
class EObjectLinkDate extends Date {
  constructor(args: number | string) {
    super(args);
  }
}

@Observed
class EObjectLinkB {
  public a: EObjectLinkDate;

  constructor(a: EObjectLinkDate) {
    this.a = a;
  }
}


@Component
struct EObjectLinkViewA {
  lable: string = "date"
  @ObjectLink a: EObjectLinkDate;

  build() {
    Column() {

      Button('点击时间+1')
        .onClick(() => {
          this.a.setDate(this.a.getDate() + 1);
        })
      DatePicker({
        start: new Date('1970-01-01'),
        end: new Date('2100-01-01'),
        selected: this.a
      })

    }

  }
}


@Component
struct EObjectLinkViewB {
  @State b: EObjectLinkB = new EObjectLinkB(new EObjectLinkDate('2024-07-16'))

  build() {
    Column() {
      EObjectLinkViewA({ lable: "date", a: this.b.a })

      Button('修改时间1')
        .onClick(() => {
          this.b.a = new EObjectLinkDate('2034-07-07')
        })

      Button('修改时间2')
        .onClick(() => {
          this.b = new EObjectLinkB(new EObjectLinkDate('2044-07-07'))
        })

    }
  }
}

























