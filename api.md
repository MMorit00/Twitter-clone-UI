在此之前你需要确定一下 api代码的一致性   要以api 为主，这里不应该有太大的改变
const express = require("express");
const auth = require("../middleware/auth");
const Notification = require("../models/notification");
const mongoose = require("mongoose");
const router = new express.Router();

// 创建新通知
router.post("/notifications", auth, async (req, res) => {
  try {
    const notification = new Notification({
      username: req.body.username,
      notificationSenderId: req.user._id,  // 发送者 ID
      notificationReceiverId: new mongoose.Types.ObjectId(req.body.notificationReceiverId),  // 接收者 ID
      notificationType: req.body.notificationType,
      postText: req.body.postText,
    });

    // 保存通知并返回完整的通知对象
    await notification.save();
    res.status(201).send(notification);  // 返回通知对象，而不是空对象
  } catch (error) {
    console.log(error);
    res.status(400).send(error); // 返回错误消息
  }
});

// 获取所有通知
router.get("/notifications", async (req, res) => {
  try {
    const notifications = await Notification.find()
      .populate("notificationSenderId", "username")
      .sort({ createdAt: -1 });
    res.send(notifications);
  } catch (error) {
    res.status(500).send(error);
  }
});

// 获取特定用户的通知
router.get("/notifications/:userId", async (req, res) => {
  try {
    const userId = new mongoose.Types.ObjectId(req.params.userId);  // 确保 userId 是 ObjectId 类型
    console.log("Fetching notifications for userId: ", userId);  // 打印 userId 用于调试
    const notifications = await Notification.find({
      notificationReceiverId: userId,
    })
      .populate("notificationSenderId", "username")
      .sort({ createdAt: -1 });

    res.send(notifications);
  } catch (error) {
    console.error(error);  // 打印错误
    res.status(500).send(error);
  }
});

module.exports = router;

const express = require("express");
const Tweet = require("../models/Tweet");
const auth = require("../middleware/auth");
const multer = require("multer");
const sharp = require("sharp");
const router = new express.Router();

// 配置 multer
const upload = multer({
  limits: {
    fileSize: 1000000, // 限制文件大小为1MB
  },
});

router.post("/tweets", auth, async (req, res) => {
  try {
    const tweet = new Tweet({
      ...req.body,
      userId: req.user._id,
    });
    await tweet.save();
    res.status(201).send(tweet);
  } catch (error) {
    res.status(400).send(error);
  }
});

// 获取所有推文可以保持公开
router.get("/tweets", async (req, res) => {
  try {
    const tweets = await Tweet.find()
      .populate("userId", "name username")
      .sort({ createdAt: -1 }); // 按时间倒序排列
    res.send(tweets);
  } catch (error) {
    res.status(500).send(error);
  }
});

// 上传推文图片路由
router.post(
  "/tweets/:id/image",
  auth,
  upload.single("image"),
  async (req, res) => {
    try {
      const tweet = await Tweet.findOne({
        _id: req.params.id,
        userId: req.user._id,
      });

      if (!tweet) {
        throw new Error("Tweet not found or unauthorized");
      }

      // 使用 sharp 处理图片
      const buffer = await sharp(req.file.buffer)
        .resize(1080) // 调整宽度,保持宽高比
        .png()
        .toBuffer();

      tweet.image = buffer;
      await tweet.save();
      res.send({ message: "Tweet image uploaded successfully" });
    } catch (error) {
      res.status(400).send({ error: error.message });
    }
  }
);

// 获取推文图片路由
router.get("/tweets/:id/image", async (req, res) => {
  try {
    const tweet = await Tweet.findById(req.params.id);

    if (!tweet || !tweet.image) {
      throw new Error("Tweet or image not found");
    }

    res.set("Content-Type", "image/png");
    res.send(tweet.image);
  } catch (error) {
    res.status(404).send({ error: error.message });
  }
});

// 点赞推文路由
router.put("/tweets/:id/like", auth, async (req, res) => {
  try {
    // 1. 查找推文
    const tweet = await Tweet.findById(req.params.id);

    if (!tweet) {
      return res.status(404).send({ error: "Tweet not found" });
    }

    // 2. 检查是否已经点赞
    if (!tweet.likes.includes(req.user._id)) {
      // 3. 添加点赞
      await Tweet.updateOne(
        { _id: req.params.id },
        {
          $push: { likes: req.user._id },
        }
      );
      res.status(200).send({ message: "Tweet has been liked" });
    } else {
      // 4. 已点赞则返回错误
      res.status(403).send({ error: "You have already liked this tweet" });
    }
  } catch (error) {
    res.status(500).send(error);
  }
});

// ... existing code ...

// 取消点赞推文路由
router.put("/tweets/:id/unlike", auth, async (req, res) => {
  try {
    // 1. 查找推文
    const tweet = await Tweet.findById(req.params.id);

    if (!tweet) {
      return res.status(404).send({ error: "Tweet not found" });
    }

    // 2. 检查是否已经点赞
    if (tweet.likes.includes(req.user._id)) {
      // 3. 移除点赞
      await Tweet.updateOne(
        { _id: req.params.id },
        {
          $pull: { likes: req.user._id },
        }
      );
      res.status(200).send({ message: "Tweet has been unliked" });
    } else {
      // 4. 未点赞则返回错误
      res.status(403).send({ error: "You have already unliked this tweet" });
    }
  } catch (error) {
    res.status(500).send(error);
  }
});


// 获取特定用户的推文
router.get("/tweets/user/:id", async (req, res) => {
  try {
    const tweets = await Tweet.find({
      userId: req.params.id,
    })
      .populate("userId", "name username")
      .sort({ createdAt: -1 });

    if (!tweets || tweets.length === 0) {
      return res.status(404).send([]);
    }

    res.send(tweets);
  } catch (error) {
    res.status(500).send(error);
  }
});


module.exports = router;

const express = require("express");
const User = require("../models/user");
const multer = require("multer");
const sharp = require("sharp");
const auth = require("../middleware/auth");
const router = express.Router();

// 配置multer
const upload = multer({
  limits: {
    fileSize: 1000000, // 限制文件大小为1MB
  },
});

router.post("/users", async (req, res) => {
  try {
    const user = new User(req.body);
    await user.save();
    res.status(201).send(user);
  } catch (error) {
    res.status(404).send(error);
  }
});

router.get("/users", async (req, res) => {
  try {
    const users = await User.find(); // 获取所有用户
    res.json(users);
  } catch (err) {
    res.status(500).json(err); // 错误处理
  }
});

// 用户登录路由
router.post("/users/login", async (req, res) => {
  try {
    // 验证用户
    const user = await User.findByCredentials(
      req.body.email,
      req.body.password
    );

    // 生成token
    const token = await user.generateAuthToken();

    // 返回用户信息和token
    res.send({ user, token });
  } catch (error) {
    res.status(400).send({
      error: error.message,
    });
  }
});

// 删除用户路由
router.delete("/users/:id", async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);

    if (!user) {
      return res.status(404).send();
    }

    res.send(user);
  } catch (error) {
    res.status(500).send(error);
  }
});

// 获取特定用户路由
router.get("/users/:id", async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).send();
    }

    res.send(user);
  } catch (error) {
    res.status(500).send(error);
  }
});

// 添加头像上传路由
router.post(
  "/users/me/avatar",
  auth,
  upload.single("avatar"),
  async (req, res) => {
    try {
      // 使用sharp处理图片
      const buffer = await sharp(req.file.buffer)
        .resize(250, 250)
        .png()
        .toBuffer();

      // 清除旧头像
      if (req.user.avatarExists) {
        req.user.avatar = null;
      }

      // 保存新头像
      req.user.avatar = buffer;
      req.user.avatarExists = true;
      await req.user.save();

      res.send({ message: "Profile image uploaded successfully" });
    } catch (error) {
      res.status(400).send({ error: error.message });
    }
  }
);

// 添加登出路由
router.post("/users/logout", auth, async (req, res) => {
  try {
    req.user.tokens = req.user.tokens.filter((token) => {
      return token.token !== req.token;
    });
    await req.user.save();
    res.send({ message: "Logged out successfully" });
  } catch (error) {
    res.status(500).send();
  }
});

// 获取用户头像路由
router.get("/users/:id/avatar", async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user || !user.avatarExists) {
      throw new Error("User or avatar not found");
    }

    res.set("Content-Type", "image/jpeg");
    res.send(user.avatar);
  } catch (error) {
    res.status(404).send({ error: error.message });
  }
});

// 关注用户路由
router.put("/users/:id/follow", auth, async (req, res) => {
  // 1. 检查是否试图关注自己
  if (req.user.id === req.params.id) {
    return res.status(403).json({ message: "你不能关注自己" });
  }

  try {
    // 2. 查找要关注的用户
    const userToFollow = await User.findById(req.params.id);
    if (!userToFollow) {
      return res.status(404).json({ message: "用户不存在" });
    }

    // 3. 检查是否已经关注
    if (userToFollow.followers.includes(req.user.id)) {
      return res.status(403).json({ message: "你已经关注了这个用户" });
    }

    // 4. 更新关注关系
    // 将当前用户ID添加到目标用户的followers数组
    await User.findByIdAndUpdate(req.params.id, {
      $push: { followers: req.user.id },
    });

    // 将目标用户ID添加到当前用户的following数组
    await User.findByIdAndUpdate(req.user.id, {
      $push: { following: req.params.id },
    });

    // 5. 返回成功响应
    res.status(200).json({ message: "关注成功" });
  } catch (error) {
    // 6. 错误处理
    res.status(500).json({ message: "服务器错误" });
  }
});

// 取消关注用户路由
router.put("/users/:id/unfollow", auth, async (req, res) => {
  // 1. 检查是否试图取消关注自己
  if (req.user.id === req.params.id) {
    return res.status(403).json({ message: "你不能取消关注自己" });
  }

  try {
    // 2. 查找要取消关注的用户
    const userToUnfollow = await User.findById(req.params.id);
    if (!userToUnfollow) {
      return res.status(404).json({ message: "用户不存在" });
    }

    // 3. 检查是否已经关注了该用户
    if (!userToUnfollow.followers.includes(req.user.id)) {
      return res.status(403).json({ message: "你还没有关注这个用户" });
    }

    // 4. 更新关注关系
    // 从目标用户的 followers 数组中移除当前用户 ID
    await User.findByIdAndUpdate(req.params.id, {
      $pull: { followers: req.user.id },
    });

    // 从当前用户的 following 数组中移除目标用户 ID
    await User.findByIdAndUpdate(req.user.id, {
      $pull: { following: req.params.id },
    });

    // 5. 返回成功响应
    res.status(200).json({ message: "已取消关注" });
  } catch (error) {
    // 6. 错误处理
    res.status(500).json({ message: "服务器错误" });
  }
});



// 更新用户资料路由
router.patch('/users/me', auth, async (req, res) => {
  try {
    // 1. 定义允许更新的字段
    const allowedUpdates = [
      'name',
      'email',
      'password',
      'website',
      'bio',
      'location'
    ];

    // 2. 获取用户请求要更新的字段
    const updates = Object.keys(req.body);

    // 3. 验证更新字段是否合法
    const isValidOperation = updates.every((update) => 
      allowedUpdates.includes(update)
    );

    // 4. 如果包含非法字段,返回错误
    if (!isValidOperation) {
      return res.status(400).send({ error: 'Invalid request' });
    }

    // 5. 遍历更新字段并应用更新
    updates.forEach((update) => {
      req.user[update] = req.body[update];
    });

    // 6. 保存更新后的用户
    await req.user.save();

    // 7. 返回更新后的用户
    res.send(req.user);

  } catch (error) {
    res.status(400).send(error);
  }
});


module.exports = router;



const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema(
  {
    notificationSenderId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: "User",
    },
    notificationReceiverId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: "User",
    },
    notificationType: {
      type: String,
      required: true,
      enum: ["like", "follow"], // 限制通知类型
    },
    postText: {
      type: String,
      trim: true,
      // 不设为必需,因为follow通知不需要此字段
    },
  },
  {
    timestamps: true,
  }
);

const Notification = mongoose.model("Notification", notificationSchema);

module.exports = Notification;


const mongoose = require("mongoose");

const tweetSchema = new mongoose.Schema(
  {
    text: {
      type: String,
      required: true,
      trim: true,
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: "User",
    },
    likes: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ],
    image: {
      type: Buffer,
    },
  },
  {
    timestamps: true, // 添加 createdAt 和 updatedAt 字段
  }
);


// 修改toJSON方法来处理图片属性
tweetSchema.methods.toJSON = function () {
  const tweet = this;
  const tweetObject = tweet.toObject();

  // 检查图片是否存在
  if (tweetObject.image) {
    tweetObject.image = true;  // 如果存在图片,将image属性设置为true
  }

  return tweetObject;
};



const Tweet = mongoose.model("Tweet", tweetSchema);

module.exports = Tweet;


const mongoose = require("mongoose");
const validator = require("validator");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");


const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    username: {
      type: String,
      required: true,
      trim: true,
      unique: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
      validate(value) {
        if (!validator.isEmail(value)) {
          throw new Error("邮箱格式不正确");
        }
      },
    },
    password: {
      type: String,
      required: true,
      trim: true,
      minlength: 7,
      validate(value) {
        if (value.toLowerCase().includes("password")) {
          throw new Error('密码不能包含 "password" 字符串');
        }
      },
    },
    avatar: {
      type: Buffer,
    },
    avatarExists: {
      type: Boolean,
      default: false,
    },
    bio: {
      type: String,
      trim: true,
    },
    website: {
      type: String,
      trim: true,
    },
    location: {
      type: String,
      trim: true,
    },
    followers: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ],
    following: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ],
    tokens: [
      {
        token: {
          type: String,
          required: true,
        },
      },
    ],
  },
  {
    timestamps: true, // 添加 createdAt 和 updatedAt 字段
  }
);

// 添加虚拟字段建立与 tweets 的关联
userSchema.virtual("tweets", {
  ref: "Tweet", // 关联的 Model
  localField: "_id", // User model 中的关联字段
  foreignField: "userId", // Tweet model 中的关联字段
});

userSchema.methods.toJSON = function () {
  const user = this;
  const userObject = user.toObject();

  // delete userObject.password;

  return userObject;
};

// 密码哈希处理：在保存用户前自动哈希密码
userSchema.pre("save", async function (next) {
  const user = this;
  if (user.isModified("password")) {
    // 仅当密码被修改时才哈希
    user.password = await bcrypt.hash(user.password, 8); // 盐轮数设为8
  }
  next(); // 必须调用next()以继续保存流程
});

// 添加用户认证的静态方法
userSchema.statics.findByCredentials = async (email, password) => {
  // 1. 通过email查找用户
  const user = await User.findOne({ email });
  if (!user) {
    throw new Error("无法登录:用户不存在");
  }

  // 2. 验证密码
  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) {
    throw new Error("无法登录:密码错误");
  }

  // 3. 验证通过返回用户
  return user;
};




// 添加生成token的方法
userSchema.methods.generateAuthToken = async function () {
  const user = this;

  // 生成token
  const token = jwt.sign(
    { _id: user._id.toString() },
    "twittercourse" // 这是私钥,实际应用中应该放在环境变量中
  );

  // 保存token
  user.tokens = user.tokens.concat({ token });
  await user.save();

  return token;
};

const User = mongoose.model("User", userSchema);

module.exports = User;
